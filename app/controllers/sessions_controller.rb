class SessionsController < ApplicationController
  def default
    if isAuth?
      redirect_to root_path
    else
      data = request.env['omniauth.auth']

      user = User.from_omniauth data

      destroy false

      create(
        user.id.to_i,
        data.credentials.token,
        data.credentials.expires_at
      )

      redirect_to params[:return_to] || root_path
    end
  end

  def create user_id, token, expires_at
    auth_key = getAuthKey user_id

    session[:abuse] = []
    session[:user_id] = user_id
    session[:access_token] = token
    session[:auth_key] = auth_key

    expires = expires_at || Time.now + 366.days
    cookies[:user_id] = {value: user_id}
    cookies[:access_token] = {value: token}#, domain: domain, expires: expires}
    cookies[:auth_key] = {value: auth_key}#, domain: domain, expires: expires}
  end

  def destroy redirect = true
    session[:access_token] = nil
    session[:user_id] = nil
    session[:auth_key] = nil
    session['ban'] = nil

    cookies.delete :access_token#, domain: domain
    cookies.delete :user_id#, domain: domain
    cookies.delete :auth_key#, domain: domain
    
    redirect_to(root_path) if redirect
  end

  def from_vk_or_for_api
    if params[:viewer_id]
      user_id = params[:viewer_id].to_i
      access_token = params[:access_token].to_i
      create user_id, access_token
      redirect_to root_path
    end
  end

private

  def domain
    DEBUG ? 'playlists.dev' : 'wpl.me'
  end
end
