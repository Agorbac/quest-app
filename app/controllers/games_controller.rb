class GamesController < ApplicationController
  before_action :require_login

  def index
    @games = current_user.games
  end

  def show
    @game = current_user.games.find(params[:id])
  end

  def new
    @game = Game.new
  end

  def create
    @game = current_user.games.build(game_params)

    if @game.save
      redirect_to @game, notice: "Игра успешно создана!"
    else
      render :new, status: :unprocessable_entity
    end
  end

   def edit
    @game = current_user.games.find(params[:id])
  end

   def update
    @game = current_user.games.find(params[:id])

    if @game.update(game_params)
      redirect_to @game, notice: "Игра обновлена!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

   def destroy
    @game = current_user.games.find(params[:id])
    @game.destroy

    redirect_to games_path, status: :see_other, notice: "Игра удалена."
  end

  private

   def game_params
    params.require(:game).permit(:info, :time, :quest_id)
  end
end