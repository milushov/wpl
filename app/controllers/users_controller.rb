# encoding: utf-8
class UsersController < ApplicationController
  respond_to :json

  before_filter :check_auth

  # GET /users
  def index
    render json: User.all.desc(:_id).limit(10)
  end

  # GET /users/1
  def show   
    format_fix if params[:format]
    
    if(user_profile = getProfile params[:id])
      render json: user_profile
    else
      error("user #{params[:id]} not found")
    end
  end

  def follow
    if user = User.where(vk_id: session[:user_id].to_s).first
      unless followee = User.any_of({_id: params[:id]}, {vk_id: params[:id]}, {screen_name: params[:id]}).first
        error 'user not found'
        return
      end
      status = user.follow(followee)
      if status.nil?
         render json: {status: true, id: params[:id]}
      elsif status == false
        error "Вы уже подписаны на этого человека [#{params[:id]}]."
      else
        error 'oO'
      end
    end
  end

  def unfollow
    if user = User.where(vk_id: session[:user_id].to_s).first
      unless followee = User.any_of({_id: params[:id]}, {vk_id: params[:id]}, {screen_name: params[:id]}).first
        error 'user not found'
        return
      end
      status = user.unfollow(followee)
      if status.nil?
        render json: {status: true, id: params[:id]}  
      elsif status == false
        error "Вы уже отписалить от этого человека [#{params[:id]}]."
      else
        error 'oO'
      end
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/1/bun?days=1&hours=10&minutes=1
  def ban
    days = params[:days] || 0
    hours = params[:hours] || 0
    minutes = params[:minutes] || 0

    @user = User.find2 params[:id]
    @user.ban = true
    @user.unban_date = Time.now + 1.days + 1.hours + 1.minutes
    @user.save!
  end

  def unban
    User.find2(params[:id]).set bun: false
  end
end