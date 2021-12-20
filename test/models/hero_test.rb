require "test_helper"

class HeroTest < ActiveSupport::TestCase
  def setup
    @game = users(:user_001).games.create(over: false, start: true)
    @game.save
  end

  test "should get valid hero" do
    @game.hero = Hero.create(alive: true, health: 50, strength: 10, 
                             defense: 5, experience: 5, room_number: 16)
    assert @game.hero.valid?
  end

  test "should not get hero without alive" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(health: 50, strength: 10, defense: 5, 
                  experience: 5, room_number: 16)
    end
  end

  test "should not get hero without health" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(alive: true, strength: 10, defense: 5, 
                               experience: 5, room_number: 16)
    end
  end

  test "should not get hero without strength" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(alive: true, health: 50, defense: 5,
                               experience: 5, room_number: 16)
    end
  end

  test "should not get hero without defense" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(alive: true, health: 50, strength: 10, 
                               experience: 5, room_number: 16)
    end
  end

  test "should not get hero without experience" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(alive: true, health: 50, strength: 10, 
                               defense: 5, room_number: 16)
    end
  end

  test "should not get hero without room number" do
    assert_raise ActiveRecord::RecordNotSaved do
      @game.hero = Hero.create(alive: true, health: 50, strength: 10, 
                               defense: 5, experience: 5)
    end
  end

  # test "should create a hero while creating a game" do
  #   @user.create
  #   game = @user.games.last
  #   assert game.hero
  # end
end
