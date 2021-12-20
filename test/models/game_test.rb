require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_001)
  end

  test "should accept a valid game" do
    game = @user.games.new(over: false, start: true)
    assert game.valid?
  end

  test "should not accept a game with no attributes" do
    game = @user.games.new
    assert_not game.valid?
  end

  test "should not accept a game with no over attribute" do
    game = @user.games.new(start: true)
    assert_not game.valid?
  end

  test "should not accept a game with no start attribute" do
    game = @user.games.new(over: false)
    assert_not game.valid?
  end

  # Revoir ce test avec les routes. 3ème réussit, 4ème échoue
  test "should be able to create a third game for a user" do
    game = @user.games.create(over: false, start: true)
    assert_equal 3, @user.games.count
  end
end
