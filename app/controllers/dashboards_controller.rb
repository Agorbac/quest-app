class DashboardsController < ApplicationController
  include SlotGenerator
  
  before_action :require_login

  def show
    @user = current_user
    @view_mode = params[:view_mode] || 'by_date'
    
    @my_games = @user.games.order(time: :desc)
    @recommended_quests = @user.recommended_quests if @user.player?

    if @user.admin? || @user.actor?
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @selected_quest = params[:quest_id].present? ? params[:quest_id].to_i : 1
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today

      if @user.admin?
        @games_by_quest = Game.joins(:quest).where('time < ?', Time.current).group('quests.name').count
        last_7_days = (6.days.ago.to_date..Date.today).to_a
        @revenue_by_day = last_7_days.map do |date|
          daily_revenue = Report.joins(:game).where(games: { time: date.beginning_of_day..date.end_of_day }).sum(:actual_amount)
          [date.strftime("%d.%m"), daily_revenue]
        end.to_h
      end

      if @view_mode == 'by_date'
        @quests = Quest.order(:id)
        @daily_slots = {}
        @quests.each do |q|
          @daily_slots[q.id] = generate_slots(q.id, @selected_date)
        end
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