class UsersController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "player" 

    if @user.save
      session[:user_id] = @user.id 
      redirect_to dashboard_path, notice: "Вы успешно зарегистрировались!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
  end
end