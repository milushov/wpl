class MainController < ApplicationController
	require 'open-uri'
	require 'openssl'

	APP_ID = 1111000
	APP_SECRET = '1111000key'
	REDIRECT_URI = 'http://playlists.dev:3000/auth'
	SETTINGS = 1+2+8+1024+2048

	def index
		if isAuth?
			@playlists = Playlist.all
			@auth_key = Digest::MD5.hexdigest( "#{session[:user_id]}_roma_123_super_salt" )
			respond_to do |format|
				format.html # index.html.erb
			end
		else
			render 'main/start'
		end
	end

	def login
		if ( session[:access_token].nil? || session[:user_id].nil? )
			requestAuth
		else
			redirect_to '/'
		end
	end

	# получает код для получения токена
	def auth
		if params[:error] and params[:error_description]
			render inline: "#{params[:error]} #{params[:error_description]}"
		end
		code = params[:code]
		url = "https://oauth.vk.com/access_token?client_id=#{APP_ID}&client_secret=#{APP_SECRET}&code=#{code}"
		response = JSON.parse open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
		if response[:error] and response[:error_description]
			render inline: "#{response[:error]} #{response[:error_description]}" and return false
		else
			saveToken(response['access_token'], response['user_id'])
			redirect_to action: 'index' and return
		end
	end

	private

	def isAuth?
		if session[:access_token] && session[:user_id] then true else false end
	end
	# запрашивает код
	def requestAuth
		url = "http://oauth.vk.com/authorize?client_id=#{APP_ID}&scope=#{SETTINGS}&redirect_uri=#{REDIRECT_URI}&response_type=code"
		redirect_to url
		return false
	end

	def saveToken( access_token, user_id )
		cookies[:access_token] = session[:access_token] = access_token
		cookies[:user_id] = session[:user_id] = user_id
		#render inline: "access_token - #{access_token}"
	end
end
