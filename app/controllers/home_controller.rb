class HomeController < ApplicationController
	before_filter :oauth
	respond_to :html, :js

	def index
		if ( @client && @ig_user )
			if ( params[:max_id] )
				@photos  = @client.user_media_feed( :max_id => params[:max_id], :count => 10 ).data
			else
				@photos  = @client.user_media_feed( :count => 10 ).data
			end
			@title = "Instagram feed for #{@ig_user.username}"

			@first_id = @photos.first.id
			@last_id  = @photos.last.id
		else
			logger.error 'failed to get client'
		end
	end
end
