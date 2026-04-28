class GamesController < ApplicationController
  include SlotGenerator
  before_action :require_login
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin? || current_user.actor?
      @games = Game.all.order(time: :desc)
    else
      @games = current_user.games.order(time: :desc)
    end
  end

  def show
  end

  def new
    @game = Game.new
    
    if params[:quest_id].present? && params[:time].present?
      @game.quest_id = params[:quest_id]
      @game.time = Time.zone.parse(params[:time])
      @confirm_mode = true
    else
      @confirm_mode = false
      @view_mode = params[:view_mode] || 'by_date'

      if @view_mode == 'by_date'
        @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
        @slots_quest_1 = generate_slots(1, @selected_date)
        @slots_quest_2 = generate_slots(2, @selected_date)
      else
        @selected_quest = params[:quest_id].present? ? params[:quest_id].to_i : 1
        @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
        
        @weekly_slots = {}
        (0..6).each do |i|
          current_day = @start_date + i.days
          @weekly_slots[current_day] = generate_slots(@selected_quest, current_day)
        end
      end
    end
  end

  def create
    @game = current_user.games.build(game_params)

    if @game.save
      redirect_to @game, notice: "Игра успешно забронирована!"
    else
      redirect_to new_game_path, alert: @game.errors.full_messages.join(", ")
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: "Информация об игре обновлена!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to dashboard_path, status: :see_other, notice: "Игра отменена/удалена."
  end

  private


  

  def set_game
    if current_user.admin? || current_user.actor?
      @game = Game.find(params[:id])
    else
      @game = current_user.games.find(params[:id])
    end
  end

  def game_params
    params.require(:game).permit(:info, :time, :quest_id)
  end
end