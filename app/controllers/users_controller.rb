class UsersController < ApplicationController
  respond_to :json

  before_filter :check_auth

  # GET /users
  def index
    render json: User.all.desc(:_id).limit(10), content_type: 'application/json'
  end

  # GET /users/1
  def show
    id = params[:id] ? params[:id] : nil

    user_profile = getProfile(id)

    if user_profile
      render json: user_profile, content_type: 'application/json'
    else
      error = { status: false, description: 'User not found' }
      render json: error, content_type: 'application/json'
    end
  end

  # POST /users
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
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

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
