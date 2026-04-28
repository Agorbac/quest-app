class DashboardsController < ApplicationController
  include SlotGenerator
  
  before_action :require_login

  def show
    @user = current_user
    @view_mode = params[:view_mode] || 'by_date'
    
    @my_games = @user.games.order(time: :desc)

    if @user.admin? || @user.actor?
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @selected_quest = params[:quest_id].present? ? params[:quest_id].to_i : 1
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today

      if @view_mode == 'by_date'
        @slots_quest_1 = generate_slots(1, @selected_date)
        @slots_quest_2 = generate_slots(2, @selected_date)
      else
        @weekly_slots = {}
        (0..6).each do |i|
          current_day = @start_date + i.days
          @weekly_slots[current_day] = generate_slots(@selected_quest, current_day)
        end
      end

      if @user.actor?
        my_schedules = @user.actor_schedules
       @actor_booked_games = Game.includes(:report).select do |game|
          my_schedules.any? { |s| s.quest_id == game.quest_id && s.day_of_week == game.time.wday }
        end
        @actor_booked_games.sort_by! { |g| g.time }.reverse! 
      end
    end
  end

  def update_role
    unless current_user.admin?
      redirect_to dashboard_path, alert: "У вас нет прав для этого действия!"
      return
    end

    target_user = User.find_by(id: params[:user_id])
    
    if target_user
      target_user.update(role: params[:role])
      redirect_to dashboard_path, notice: "Права пользователя ##{target_user.id} обновлены на: #{target_user.role}"
    else
      redirect_to dashboard_path, alert: "Пользователь с таким ID не найден."
    end
  end
end