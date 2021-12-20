require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @game = users(:user_001).games.create(over: false, start: true)
    @game.save
  end

  test "should accept valid message" do
    message = @game.messages.new(body: "Hello world")
    assert message.valid?
  end

  test "should not accept message with no body" do
    message = @game.messages.new
    assert_not message.valid?
  end

  test "should not accept message with empty string" do
    message = @game.messages.new(body: "   ")
    assert_not message.valid?
  end
end
