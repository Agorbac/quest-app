class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_game_and_dependencies
  before_action :require_actor_or_admin

  def show
    @report = @game.report
  end

  def new
    if @game.report.present?
      redirect_to game_report_path(@game)
    else
      @report = @game.build_report
    end
  end

def create
    @report = @game.build_report(report_params)
    
    if @report.save
      actor = @report.actual_actor || @game.user
      
      if @report.photo_sold
        ActorTransaction.create!(
          user: actor, 
          game: @game, 
          transaction_type: 'plus', 
          category: 'photo', 
          amount: ActorTransaction::RATES['photo']
        )
      end
      
      if @report.players_count.to_i > 4
        ActorTransaction.create!(
          user: actor, 
          game: @game, 
          transaction_type: 'plus', 
          category: 'upsell', 
          amount: ActorTransaction::RATES['upsell']
        )
      end

      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
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