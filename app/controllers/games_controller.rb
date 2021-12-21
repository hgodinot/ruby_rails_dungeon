class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_games, only: [:new, :index]
  
  def index
  end

  def show
    find_game
    @board = @game.generate_board
    @commands = @game.avalaible_commands
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = "You don't have access to this game."
    redirect_to root_path
  end

  def create(new = true)
    @game = current_user.games.new(over: false, start: new) # No pre-start screen if game created with the "Play Again" button.
    if current_user.games.count < 3 && @game.save
      flash[:success] = "And so your adventure begins. May you critical hit your way to the end!"
      @game.start_setup
      redirect_to @game
    else
      flash[:danger] = "No more than 3 games."
      set_games
      redirect_to root_path
    end
  end

  def destroy
    find_game
    @game.destroy

    redirect_to root_path
  end

  def update
    find_game
    clean_messages
    @game.clean_hero_room
    @game.update_hero_room(params[:commit])
    redirect_to @game
  end

  def choose
    find_game
    clean_messages
    @game.resolve_choice(params[:commit][-1])
    redirect_to @game
  end

  def start
    find_game
    @game.start_adventure
    redirect_to @game
  end

  def play_again
    find_game
    @game.destroy
    set_games
    if @games.size > 0
      redirect_to root_path
    else
      create(false)
    end
  end

  private

    def set_games
      @games = current_user.games.all.sort_by { |game| game.updated_at }.reverse
    end

    def find_game
      @game = current_user.games.find(params[:id])
    end

    def clean_messages # Clean all old messages after moving or making a choice
      @game.messages.each { |message| message.destroy }
    end
end