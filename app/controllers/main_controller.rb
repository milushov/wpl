# encoding: utf-8
class MainController < ApplicationController
  require 'open-uri'
  require 'openssl'

  def index
    format_fix if params[:format]

    if isAuth?
      @user_profile = getProfile session[:user_id]
      
      unless @user_profile
        flash[:error] = 'Невозможно вас авторизовать'
      end
      
      # if the token id obsoleted
      if @user_profile.kind_of? Integer
        cookies.delete :auth_key#, domain: get_domain
        return redirect_to '/auth/vkontakte'
      end

      @count_friends = ApplicationController::COUNT_FRIENDS.max + 1 # depricated
      @api_url = ApplicationController::APP_URL # main url of application
      @debug = ApplicationController::DEBUG
      
      render 'main/index'
    else
      # переводим юзера на стартовую страницу приложения
      @return_to = params[:path] ? "?return_to=#{params[:path]}" : nil
      render 'main/start'
    end
  end

private

  def blacklist
    error 'you are in blacklist by ip'
  end
end