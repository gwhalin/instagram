class LikesController < ApplicationController
	before_filter :oauth
	respond_to :html, :js

	def index
		if ( @client && @ig_user )
			@title = "Instagram feed for #{@ig_user.username} likes"

			if ( params[:max_id] )
				@photos  = @client.user_liked_media( { :max_like_id => params[:max_id], :count => 10 } ).data
			else
				@photos  = @client.user_liked_media( { :count => 10 } ).data
			end

			@first_id = @photos.first.id
			@last_id  = @photos.last.id

			logger.info( "Got #{@photos.size} photos" )
		else
			logger.error 'failed to get client'
			redirect_to :controller => 'home', :action => 'index' and return false
		end
	end
end
