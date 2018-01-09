class RelationshipsController < ApplicationController
  before_action :logged_in_user

  # getting the follow and unfollow buttons to work by finding the user associated with the followed_id
  def create
  	@user = User.find(params[:followed_id])
  	current_user.follow(@user)
  	respond_to do |format|
  	  format.html { redirect_to @user }
  	  format.js
  	  # this arranges for the Relationships controller to respond to Ajax requests
  	end
  end

  def destroy
  	@user = Relationship.find(params[:id]).followed
  	current_user.unfollow(@user)
  	respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
