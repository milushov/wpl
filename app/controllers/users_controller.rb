# encoding: utf-8
class UsersController < ApplicationController
  respond_to :json

  before_filter :check_auth

  # GET /users
  def index
    render json: User.all.desc(:_id).limit(10).to_a.map { |user| user.show }
  end

  # GET /users/1
  def show   
    format_fix if params[:format]
    
    if user_profile = getProfile(params[:id])
      check_auth if user_profile == -1
      render json: user_profile
    else
      error("user #{params[:id]} not found")
    end
  end

  def follow
    do_follow
  end

  def unfollow
    do_follow :undo
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

  private

  def do_follow undo = nil
    if user = User.find(session[:user_id].to_i)
      unless followee = User.any_of({_id: params[:id].to_i}, {screen_name: params[:id]}).first
        return error "user:#{params[:id]} not found"
      end
      
      status = !undo ? user.follow(followee) : user.unfollow(followee)
      
      if status.nil?
         render json: {status: true, id: params[:id]}
      elsif status == false
        error "Вы уже #{ !undo ? 'подписаны на' : 'отписаны от'} этого человека:#{params[:id]}."
      else
        error 'o_O'
      end
    end
  end
end