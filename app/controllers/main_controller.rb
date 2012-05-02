class MainController < ApplicationController
  require 'open-uri'
  require 'openssl'

  def index
    if isAuth?
      # here we will be select user profile by vk_id,
      # if profile don't extst (@user_profile will be equal false),
      # we create user...
      @user_profile = getProfile(session[:user_id])

      unless @user_profile
        user_info = @app.users.get(
          uids: session[:user_id],
          fields: 'screen_name'
        )[0]

        User.create!(
          vk_id: user_info['uid'].to_i,
          screen_name: user_info['screen_name']
        )

        @user_profile = getProfile(session[:user_id])

        unless @user_profile
          render 'main/start' and return
        end
      end

      @playlists = @user_profile[:playlists]
      
      # auth_key будет посылать в хедаре при каждом запросе к апи
      @auth_key = Digest::MD5.hexdigest( "#{session[:user_id]}_roma_123_super_salt" )
      
      respond_to do |format|
        format.html # index.html.haml
      end
    else
      # переводим юзера на стартовую страницу приложения
      @return_to = params[:path] ? "?return_to=#{params[:path]}" : nil
      render 'main/start'
    end
  end

  def login
    if isAuth?
      redirect_to action: 'index'
    elsif
      # try to get auth_token
      requestAuth params[:return_to]
    end
  end

  def logout
    cookies[:access_token] = session[:access_token] = nil
    cookies[:user_id] = session[:user_id] = nil
    cookies[:auth_key] = session[:auth_key] = nil
    redirect_to action: 'index'
  end

  # получает код для получения токена
  def auth
    if params[:code].nil?
      redirect_to action: 'index'
    elsif params[:error] and params[:error_description]
      render inline: "#{params[:error]} - #{params[:error_description]}" and return
    end

    uri = "https://oauth.vk.com/access_token?client_id=#{ APP_ID }&client_secret=#{ APP_SECRET }&code=#{params[:code]}"

    begin
      response = open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    rescue => ex
      render inline: "#{ex.class}: #{ex.message} uri(#{uri}) <b>failed</b>" and return
    end

    response = JSON.parse response

    if response[:error] and response[:error_description]
      render inline: "#{params[:error]} - #{params[:error_description]}" and return
    else
      saveToken response['access_token'], response['user_id']
      if params[:return_to]
        redirect_to "/#{params[:return_to]}"
      else
        redirect_to action: 'index'
      end
    end
  end

  private

  # запрашивает код, нужный для получения токена
  def requestAuth(return_to = nil)
    redirect_uri = return_to ? "#{REDIRECT_URI}?return_to=#{return_to}" : REDIRECT_URI
    redirect_to "http://oauth.vk.com/authorize?client_id=#{ APP_ID }&scope=#{ SETTINGS }&redirect_uri=#{ redirect_uri }&response_type=code"
  end

  # сохраняет access_token, user_id, auth_key в сессии, куке
  def saveToken( access_token, user_id )
    cookies[:access_token] = session[:access_token] = access_token
    cookies[:user_id] = session[:user_id] = user_id
    cookies[:auth_key] = session[:auth_key] = getAuthKey user_id
  end
end