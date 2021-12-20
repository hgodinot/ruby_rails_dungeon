require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "💎 Ruby & Rails Dungeon 🏰"
    get '/users/sign_in'
    sign_in users(:user_001)
    post user_session_url
    follow_redirect!
    assert_response :success
    @user = users(:user_001)
    @game = games(:one)
  end

  test "should get root" do
    get root_url
    assert_response :success
    assert_select "title", @base_title
  end

  test "should get index" do
    get games_path
    assert_response :success
    assert_select "title", @base_title
  end

  test "should get show" do
    get game_path(@game)
    assert_response :success
    assert_select "title", @base_title
  end

  test "should create a new game" do
    post games_path
    assert_redirected_to game_path(@user.games.last)
  end

  test "should delete a game and all associated objects" do
    assert_equal 2, @user.games.count
    assert_equal 2, Hero.all.size
    assert_equal 2, Message.all.size
    assert_equal 2, Room.all.size

    delete game_path(@game)

    assert_equal 1, @user.games.count
    assert_equal 1, Hero.all.size
    assert_equal 1, Message.all.size
    assert_equal 1, Room.all.size
  end
end
