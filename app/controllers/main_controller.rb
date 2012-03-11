class MainController < ApplicationController
	require 'open-uri'
	require 'openssl'

	APP_ID = 1111000
	APP_SECRET = '1111000key'
	REDIRECT_URI = 'http://playlists.dev:3000/auth'
	SETTINGS = 'notify,friends,photos,audio' # 1+2+4+8

	def index
		if isAuth?
			# сдесь будем выбирать профиль пользователя по vk_id
			@playlists = Playlist.all
			# auth_key будет посылать в хедаре при каждом запросе к апи
			@auth_key = Digest::MD5.hexdigest( "#{session[:user_id]}_roma_123_super_salt" )
			respond_to do |format|
				format.html # index.html.haml
			end
		else
			render 'main/start'
		end
	end

	def login
		if ( session[:access_token].nil? || session[:user_id].nil? )
			if( params[:return_to] ) 
				requestAuth( params[:return_to] )
			else
				requestAuth
			end
		else
			redirect_to '/'
		end
	end

	def logout
		if ( session[:access_token].nil? || session[:user_id].nil? )
			redirect_to '/'
		else
			cookies[:access_token] = session[:access_token] = nil
			cookies[:user_id] = session[:user_id] = nil
			redirect_to '/'
		end
	end

	# получает код для получения токена
	def auth(return_to = nil)
		if params[:code].nil?
			redirect_to '/' and	return
		elsif params[:error] and params[:error_description]
			render inline: "#{params[:error]} - #{params[:error_description]}" and return
		end
		uri = "https://oauth.vk.com/access_token?client_id=#{ APP_ID }&client_secret=#{ APP_SECRET }&code=#{params[:code]}"
		response = JSON.parse open(uri, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
		if response[:error] and response[:error_description]
			render inline: "#{params[:error]} - #{params[:error_description]}" and return
		else
			saveToken(response['access_token'], response['user_id'])
			unless params[:return_to] then redirect_to action: 'index' and return else
				redirect_to "/#{params[:return_to]}" and return
			end
		end
	end

	private

	def isAuth?
		if session[:access_token] && session[:user_id] then true else false end
	end

	# запрашивает код
	def requestAuth(return_to = nil)
		redirect_uri = return_to ? "#{REDIRECT_URI}?return_to=#{return_to}" : REDIRECT_URI
		uri = "http://oauth.vk.com/authorize?client_id=#{ APP_ID }&scope=#{ SETTINGS }&redirect_uri=#{ redirect_uri }&response_type=code"
		#render inline: uri and return
		redirect_to uri
		return false
	end

	def saveToken( access_token, user_id )
		cookies[:access_token] = session[:access_token] = access_token
		cookies[:user_id] = session[:user_id] = user_id
		#render inline: "access_token - #{access_token}"
	end
end
