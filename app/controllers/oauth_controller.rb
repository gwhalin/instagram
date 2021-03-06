class OauthController < ApplicationController

	require "rubygems"
	require "instagram"

	CLIENT_ID     = '3c85316c8d4b43e4b10bafce785c7cdd'
	CLIENT_SECRET = '8b72c1d355314081a2e44bf825b245b8'

	def index
		if ( session[:logout] )
			logger.info "logging this user out"
			@logout = true
			reset_session
		elsif ( checkAuth )
				logger.info "already logged in as #{@user.id}"
				redirect_to :controller => 'home' and return false
		end
	end

	def connect
		Instagram.configure do |config|
			config.client_id = CLIENT_ID
			config.client_secret = CLIENT_SECRET
		end

		callback_url = url_for :controller => 'oauth', :action => 'callback'
		logger.info "sending to ig url for oauth: #{Instagram.authorize_url( :redirect_uri => callback_url )}"
		redirect_to Instagram.authorize_url( :redirect_uri => callback_url )
	end

	def callback
		callback_url = url_for :controller => 'oauth', :action => 'callback'
		response = Instagram.get_access_token( params[:code], :redirect_uri => callback_url )
		token = response.access_token

		reset_session

		if ( token )
			logger.info "got token: #{response.access_token}"
			begin
				user_by_token = User.find_by_token( token )
				user_by_token.touch
				session[:user] = user_by_token.id
			rescue
				# get remote id
				client = Instagram.client( :access_token => token )
				if ( client )
					ig_user = client.user

					if ( ig_user )
						now = Time.now
						user = User.new( :token => token, :igram_id => ig_user.id, :atime => now, :created_at => now )
						user.save
						session[:user] = user_by_token.id
					else
						logger.error "failed to get client using token #{token}"
					end
				else
					logger.error "failed to get client using token #{token}"
				end
			end
		else
			logger.error 'failed to get token'
		end
		redirect_to :controller => 'home' and return false
	end
end
