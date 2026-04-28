class ActorTransactionsController < ApplicationController
  before_action :require_login
  before_action :require_staff

  def index
    @actors = User.actor.order(:id)
  end

  def create
    unless current_user.admin?
      redirect_to motivation_path
      return
    end

    @transaction = ActorTransaction.new(transaction_params)
    @transaction.amount = ActorTransaction::RATES[params[:actor_transaction][:category]] || params[:actor_transaction][:amount]
    
    if @transaction.save
      redirect_to motivation_path
    else
      redirect_to motivation_path
    end
  end

  private

  def require_staff
    unless current_user.admin? || current_user.actor?
      redirect_to dashboard_path
    end
  end

  def transaction_params
    params.require(:actor_transaction).permit(:user_id, :category, :amount, :transaction_type, :comment)
  end
end