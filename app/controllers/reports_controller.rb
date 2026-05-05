class ReportsController < ApplicationController
  include GamesHelper
  before_action :require_login
  before_action :set_game_and_dependencies
  before_action :require_actor_or_admin

  def show
    @report = @game.report
  end

def new
  @game = Game.find(params[:game_id])
  @report = @game.build_report

  if params[:blank_photo].present?
    begin

      image_path = params[:blank_photo].path

      ocr = RTesseract.new(image_path, lang: 'rus+eng')
      text = ocr.to_s

      price_match = text.match(/(?:МЕСТЕ|СУММА)[:\s]*(\d{3,5})/i)
      @report.actual_amount = price_match[1] if price_match

      player_lines = text.scan(/^\s*\d\s*\)/).size
      @report.players_count = player_lines if player_lines > 0

      flash.now[:notice] = "Данные с бланка успешно считаны!"
    rescue => e
      flash.now[:alert] = "Ошибка распознавания: #{e.message}"
    end
  end
end

def create
  @game = Game.find(params[:game_id])
  @report = @game.build_report(report_params)
  @actors = User.where(role: [:actor, :admin])
  @base_price = slot_price(@game.time)

if params[:analyze_photo] && params[:blank_photo].present?
  begin
    image = MiniMagick::Image.open(params[:blank_photo].path)
    image.format "jpg"
    image.colorspace "Gray"
    image.contrast
    image.normalize

    processed_path = Rails.root.join('tmp', "ocr_#{Time.now.to_i}.jpg")
    image.write(processed_path)

    ocr = RTesseract.new(processed_path.to_s, lang: 'rus+eng', psm: 6)
    raw_text = ocr.to_s
    
    text_for_numbers = raw_text.gsub(/S/i, '5').gsub(/[OJ]/i, '0')

    puts "=== RAW TESSERACT TEXT ==="
    puts raw_text
    puts "=== PROCESSED FOR NUMBERS ==="
    puts text_for_numbers
    puts "============================="

    price_match = text_for_numbers.match(/(?:MECTE|МЕСТЕ|СУММА|rant|AbILIN|MECT|MEC)[\s\W]*(\d[\s\.]*\d[\s\.]*\d[\s\.]*\d?)/i)
    if price_match
      clean_amount = price_match[1].gsub(/[\s\.]/, '').to_i
      @report.actual_amount = clean_amount
      @report.calculated_amount = clean_amount
    end

    discount_match = text_for_numbers.match(/(?:СКИДКА|CKHAKA|CKMAKA|CKUGKA|CКИДKA|CKM|CK)[\s\W]*(\d{2,4})/i)
    if discount_match
      discount_val = discount_match[1].to_i
      if [500, 1000].include?(discount_val)
        @report.discount_type = discount_val.to_s
      else
        @report.discount_type = "other"
        @report.discount_custom = discount_val
      end
    end

    player_numbers = text_for_numbers.scan(/(?:^|\s|\||\[)(\d)\s*[\)\.\]]/).flatten.map(&:to_i).select { |n| n > 0 && n <= 15 }
    @report.players_count = player_numbers.max if player_numbers.any?

    flash.now[:notice] = "ИИ распознал: Игроков: #{@report.players_count || '-'}, Сумма: #{@report.actual_amount || '-'} ₽, Скидка: #{discount_match ? discount_val : 'нет'}."
  rescue => e
    flash.now[:alert] = "Ошибка OCR: #{e.message}"
  ensure
    File.delete(processed_path) if defined?(processed_path) && File.exist?(processed_path)
  end
  render :new and return
end



  if @report.save
    redirect_to dashboard_path, notice: "Отчет успешно сохранен!"
  else
    render :new, status: :unprocessable_entity
  end
end

private

def report_params
  params.require(:report).permit(:source_type, :source_name, :actual_actor_id, :payment_method, :players_count, :discount_type, :discount_custom, :photo_sold, :photo_payment, :extra_expenses, :comment, :calculated_amount, :actual_amount, :amount_mismatch_reason)
end

  def edit
    @report = @game.report
  end

  def update
    @report = @game.report
    
    if @report.update(report_params)
      redirect_to game_report_path(@game)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_game_and_dependencies
    @game = Game.find(params[:game_id])
    @actors = User.actor
    @base_price = calculate_price(@game.time)
  end

  def calculate_price(time)
    case time.hour
    when 9..11 then 1000
    when 12..17 then 2000
    else 3000
    end
  end

  def require_actor_or_admin
    unless current_user.admin? || current_user.actor?
      redirect_to dashboard_path
    end
  end

  def report_params
    params.require(:report).permit(
      :source_type, :source_name, :actual_actor_id, :payment_method,
      :players_count, :discount_type, :discount_custom, :photo_sold,
      :photo_payment, :extra_expenses, :comment, :calculated_amount,
      :actual_amount, :amount_mismatch_reason, :blank_photo
    )
  end
end