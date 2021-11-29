require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "Friday Night Dungeon"
  end
  
  test "should get root" do
    get root_url
    assert_response :success
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get new" do
    get games_new_url
    assert_response :success
    assert_select "title", "New Game | #{@base_title}"
  end
end
