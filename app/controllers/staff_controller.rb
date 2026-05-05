class StaffController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @actors = User.actor.order(:id)
  end

  def monthly_report
    @month = params[:month].present? ? Date.parse(params[:month]) : Date.today.beginning_of_month
    @reports = Report.includes(:game, :actual_actor)
                     .where(games: { time: @month.beginning_of_month..@month.end_of_month })
                     .order('games.time DESC')
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "monthly_report_#{@month.strftime('%Y_%m')}",
               template: "staff/monthly_report",
               formats: [:html],
               layout: "pdf",
               encoding: "UTF-8"
      end
    end
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to dashboard_path, alert: "У вас нет прав для просмотра этой страницы!"
    end
  end
end