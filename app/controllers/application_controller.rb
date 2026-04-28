class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Пожалуйста, войдите в систему."
    end
  end

  def redirect_if_logged_in
    if logged_in?
      redirect_to dashboard_path
    end
  end
end