require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:taka)
  end
  
  test "layout links when not logged-in" do
  	get root_path
  	assert_template 'pages/home'
  	assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", about_path, count: 2
    assert_select "a[href=?]", signup_path, count: 2
    assert_select "a[href=?]", login_path
    get about_path
    assert_select "title", full_title("About")
  end

  test "layout links when logged-in" do
    log_in_as(@user)
    assert_redirected_to @user
    get root_path
    assert_template 'pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", about_path, count: 2
    assert_select "a[href=?]", signup_path, count: 0
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", edit_user_path(@user)
  end
end
