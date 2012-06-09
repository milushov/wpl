class MainController < ApplicationController
  require 'open-uri'
  require 'openssl'

  def index
    format_fix if params[:format]

    # if we come from application vk.com/app111111
    if params[:viewer_id]
      user_id = params[:viewer_id].to_i
      access_token = params[:access_token].to_i
      # auth_key = params[:auth_key].to_i
      saveToken access_token, user_id
    end

    if isAuth?
      # here we will be select user profile by id,
      # if profile don't extst (@user_profile will be equal false),
      # we create user...
      @user_profile = getProfile session[:user_id]
      
      unless @user_profile
        create_user
        unless(@user_profile = getProfile session[:user_id])
          return render 'main/start'
        end
      end
      
      if @user_profile.kind_of? Integer
        cookies['auth_key'] = 'oops, you will not be able to auth'
        return redirect_to action: 'login', return_to: params[:path]
      end

      @count_friends = ApplicationController::COUNT_FRIENDS.max + 1 # depricated
      @app_url = ApplicationController::APP_URL # main url of application
      @debug = ApplicationController::DEBUG
      if @debug
        @api_url = "http://#{env['HTTP_HOST']}/"
      else
        n = rand INSTANCES
        @api_url = "http://#{n}.#{@@domain}/"
      end
      
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
    # binding.pry
    if isAuth?
      redirect_to action: 'index'
    else
      requestAuth params[:return_to] # try to get auth_token
    end
  end

  def logout
    session[:access_token] = nil
    session[:user_id] = nil
    session[:auth_key] = nil
    session['ban'] = nil

    domain = '.' + @@domain[/[^\.]*\.[^\.]*$/]

    cookies.delete :access_token, domain: domain
    cookies.delete :user_id, domain: domain
    cookies.delete :auth_key, domain: domain

    redirect_to action: 'index'
  end

  # step2: obtain and save access token
  def auth
    if params[:code].nil?
      redirect_to action: 'index'
    elsif params[:error] and params[:error_description]
      return render inline: "#{params[:error]} - #{params[:error_description]}"
    end

    uri = "https://oauth.vk.com/access_token?client_id=#{ APP_ID }&client_secret=#{ APP_SECRET }&code=#{params[:code]}"

    begin
      response = open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    rescue => ex
      return render inline: "#{ex.class}: #{ex.message} uri(#{uri}) <b>failed</b>" 
    end

    response = JSON.parse response

    if response[:error] and response[:error_description]
      return render inline: "#{params[:error]} - #{params[:error_description]}"
    else
      saveToken response['access_token'], response['user_id']
      if params[:return_to]
        redirect_to "/#{params[:return_to]}"
      else
        redirect_to action: 'index'
      end
    end
  end

  def blacklist
    error 'you in blacklist by ip'
  end

  private
    def create_user
      user_info = @vk.users.get(
        uids: session[:user_id],
        lang: 'ru', # REMARK: not tested!
        fields: 'photo_big,screen_name,sex'
      ).first

      user_info[:id] = user_info[:uid]
      user_info.delete 'uid'

      User.create! user_info
    end

    # first step: request code, which is required for getting auth token
    def requestAuth(return_to = nil)
      domain = "http://#{@@domain}/auth"
      redirect_uri = return_to ? "#{domain}?return_to=#{return_to}" : domain
      redirect_to "http://oauth.vk.com/authorize?client_id=#{ APP_ID }&scpoe=#{ SETTINGS }&redirect_uri=#{ redirect_uri }&response_type=code"
    end

    # сохраняет access_token, user_id, auth_key в сессии, куке
    def saveToken( access_token, user_id )
      session[:abuse] = []

      access_token = session[:access_token] = access_token
      user_id = session[:user_id] = user_id.to_i
      auth_key = session[:auth_key] = getAuthKey user_id.to_i
      
      domain = '.' + @@domain
      expires = Time.now + 366.days

      cookies[:access_token] = {value: access_token, domain: domain, expires: expires}
      cookies[:user_id] = {value: user_id, domain: domain, expires: expires}
      cookies[:auth_key] = {value: auth_key, domain: domain, expires: expires}
    end
end