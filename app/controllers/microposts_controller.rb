class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  def create
  	@micropost = current_user.microposts.build(micropost_params)
  	if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'pages/home'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  	@micropost.destroy
  	flash[:success] = "Micropost deleted"
  	redirect_to request.referrer || root_url
  	# this is a request.referrer method, related to the request.original_url
  	# it refers to the previous URL
  	# by using request.referrer, we arrange to redirect back to the page issuing the delete request in both Home page or user's profile page
  	# if the referring URL is nil, it will redirect to root_url as default
  	# or we can also use:
  	# redirect_back(fallback_location: root_url)
  end




  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
