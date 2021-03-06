# encoding: utf-8
class UsersController < ApplicationController
  before_filter :check_auth
  respond_to :json

  before_filter :check_auth

  # GET /users
  def index
    render json: User.all.desc(:_id).limit(10).to_a.map { |user| user.show }
  end

  # GET /users/1
  def show   
    format_fix if params[:format]

    # return render json: User.any_of({screen_name: params[:id]}, {_id: params[:id].to_i}).first
    # return render json: User.find2(params[:id])

    if user_profile = getProfile(params[:id])
      check_auth if user_profile == -1
      render json: user_profile
    else
      error "user #{params[:id]} not found"
    end
  end

  def follow
    do_follow
  end

  def unfollow
    do_follow :undo
  end

  # POST /users/1/ban?days=1&hours=10&minutes=1
  def ban
    days = params[:days] || 0
    hours = params[:hours] || 0
    minutes = params[:minutes] || 0

    @user = User.find2 params[:id]
    @user.ban = true
    @user.unban_date = Time.now + 1.days + 1.hours + 1.minutes
    status = @user.save
    render json: {status: status, id: user.id}
  end

  def unban
    user = User.find2 params[:id]
    status = user.set bun: false
    render json: {status: status, id: user.id }
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