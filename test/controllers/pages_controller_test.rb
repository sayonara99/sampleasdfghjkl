require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
  	@base_title = "Ruby on Rails Tutorial Sample App"
  end

  test "should get root" do
    get root_path
    assert_response :success
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

end
