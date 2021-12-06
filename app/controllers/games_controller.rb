class GamesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @games = current_user.games
  end

  def show
    @game = Game.find(params[:id])
  end
  
  def new
    @game = current_user.games.new
  end

  def create
    @game = current_user.games.new
    if @game.save
      redirect_to @game #?
    #else
      #render :new
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    redirect_to root_path
  end
end
