class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :app_init

  APP_ID = 1111000
  APP_SECRET = '1111000key'
  REDIRECT_URI = 'http://playlists.dev:3000/auth'
  SETTINGS = 'notify,friends,photos,audio' # 1+2+4+8

  private

  def app_init
    @app = VK::Serverside.new app_id:APP_ID, app_secret: APP_SECRET
    if isAuth?
      @app.access_token = session[:access_token]
      #@app.settings = SETTINGS
    end   
  end

  def isAuth?
    session[:access_token] and session[:user_id]
  end

  def error(d = 'not found')
    error = { status: false, description: d }
    render json: error, content_type: 'application/json' and return
  end
end