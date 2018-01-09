require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
  	@user = users(:taka)
  end

  test "profile display" do
  	get user_path(@user)
  	assert_template 'users/show'
  	assert_select 'title', full_title(@user.name)
  	assert_select 'h1', text: @user.name
  	assert_select 'h1>img.gravatar'
  	assert_match @user.microposts.count.to_s, response.body
  	# we want the number of microposts to appear somewhere on the page
  	assert_select 'div.pagination'
  	@user.microposts.paginate(page: 1).each do |micropost|
  	  assert_match micropost.content, response.body
  	end
    assert_match "#{@user.following.count}", response.body
    assert_match "#{@user.followers.count}", response.body
  end
  	
end
