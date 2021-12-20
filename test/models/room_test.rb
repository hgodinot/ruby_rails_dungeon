require "test_helper"

class RoomTest < ActiveSupport::TestCase
  def setup
    @game = users(:user_001).games.create(over: false, start: true)
    @game.save
  end

  test "should get valid room" do
    room = @game.rooms.new(encounter: "None", visited: false)
    assert room.valid?
  end

  test "should not get room without encounter" do
    room = @game.rooms.new(visited: false)
    assert_not room.valid?
  end

  test "should not get room without visited" do
    room = @game.rooms.new(encounter: "None")
    assert_not room.valid?
  end
end
