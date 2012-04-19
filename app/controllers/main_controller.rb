class MainController < ApplicationController
  require 'open-uri'
  require 'openssl'

  def index
    if isAuth?
      # сдесь будем выбирать профиль пользователя по vk_id
      @user_profile = getProfile(session[:user_id])

      unless @user_profile
        render 'main/start' and return
      end

      @playlists = @user_profile[:playlists]
      
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
    if session[:access_token].nil? or session[:user_id].nil?
      requestAuth params[:return_to]
    else
      redirect_to action: 'index'
    end
  end

  def logout
    cookies[:access_token] = session[:access_token] = nil
    cookies[:user_id] = session[:user_id] = nil
    redirect_to action: 'index'
  end

  def tags
    render json: %w{rock sport sex health thinking love jazz etc}
  end

  # получает код для получения токена
  def auth(return_to = nil)
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

  # запрашивает код
  def requestAuth(return_to = nil)
    redirect_uri = return_to ? "#{REDIRECT_URI}?return_to=#{return_to}" : REDIRECT_URI
    redirect_to "http://oauth.vk.com/authorize?client_id=#{ APP_ID }&scope=#{ SETTINGS }&redirect_uri=#{ redirect_uri }&response_type=code"
  end

  def saveToken( access_token, user_id )
    @app.access_token = cookies[:access_token] = session[:access_token] = access_token
    cookies[:user_id] = session[:user_id] = user_id
  end
end