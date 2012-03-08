class UsersController < ApplicationController
  respond_to :json

  # GET /users
  # GET /users.json
  def index
    render json: User.all.desc(:_id).limit(10), content_type: 'application/json'
  end

  # GET /users/1
  # GET /users/1.json
  def show
    id = params[:id]
    @user = Hash.new {0}
    @user[:info] = User.any_of({vk_id: id}, {_id: id}).first
    if !@user[:info].nil?
      @user[:followers_count] = @user[:info].followers_count_by_model('User')
      @user[:followers] = @user[:info].all_followers_by_model('User')

      @user[:followees_count] = @user[:info].followees_count_by_model('User')
      @user[:followees] = @user[:info].all_followees_by_model('User')

      @user[:playlists_count] = @user[:info].followees_count_by_model('Playlist')
      @user[:playlists] = @user[:info].all_followees_by_model('Playlist')
    else
      redirect_to action: :not_found
      return
    end
    render json: @user, content_type: 'application/json'
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
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
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
