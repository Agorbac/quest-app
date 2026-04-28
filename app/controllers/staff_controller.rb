class StaffController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def index
    @actors = User.actor.order(:id)
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to dashboard_path, alert: "У вас нет прав для просмотра этой страницы!"
    end
  end
end