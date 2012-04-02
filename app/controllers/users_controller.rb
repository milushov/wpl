class UsersController < ApplicationController
  respond_to :json

  # GET /users
  def index
    render json: User.all.desc(:_id).limit(10), content_type: 'application/json'
  end

  # GET /users/1
  def show
    id, user_s = params[:id] ? params[:id] : nil, {}

    user_s[:info] = User.any_of({screen_name: id}, {vk_id: id}, {_id: id}).first
    
    if user_s[:info].nil?
      #error('User not found') #???
      error = { status: false, description: 'User not found' }
      render json: error, content_type: 'application/json' and return
    else
      user_s[:followers_count] = user_s[:info].followers_count_by_model('User')
      user_s[:followers] = user_s[:info].all_followers_by_model('User')

      user_s[:followees_count] = user_s[:info].followees_count_by_model('User')
      user_s[:followees] = user_s[:info].all_followees_by_model('User')

      user_s[:playlists_count] = user_s[:info].followees_count_by_model('Playlist')
      user_s[:playlists] = user_s[:info].all_followees_by_model('Playlist')

      user_s[:status] = true      
    end

    user_vk_id = user_s[:info][:vk_id]

    followers_vk_ids = []
    user_s[:followers].each{ |v| followers_vk_ids << v[:vk_id] }

    followees_vk_ids = []
    user_s[:followees].each{ |v| followees_vk_ids << v[:vk_id] }

    
    user_vk_profile = getProfilesData user_vk_id, followers_vk_ids, followees_vk_ids
    #user_vk_profile = getProfilesData 788157, [1,2], [1,788157]

    user_profile = {}
    user_profile[:user] = user_vk_profile['user']
    user_profile[:user][:id] = user_s[:info][:_id]
    user_profile[:user][:followers_count]= user_s[:followers_count] + user_vk_profile['app_friends'].count
    user_profile[:user][:followees_count]= user_s[:followees_count] + user_vk_profile['app_friends'].count
    user_profile[:user][:playlists_count]= user_s[:playlists_count]
    
    user_vk_profile['followers'].each do |v|
      temp = user_s[:followers].select { |val| v['uid'] == val[:vk_id] }
      v[:id] = temp.empty? ? nil : temp[0][:_id]
    end

    user_vk_profile['followees'].each do |v|
      temp = user_s[:followees].select { |val| v['uid'] == val[:vk_id] }
      v[:id] = temp.empty? ? nil : temp[0][:_id]
    end
    
    user_profile[:followers] = user_vk_profile['followers']
    user_profile[:followees] = user_vk_profile['followees']
    user_profile[:playlists] = user_s[:playlists]
    user_profile[:status] = true

    render json: user_profile, content_type: 'application/json'
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

  private

  # принимает 2 массива id-шников vk и 1 id'шник юзера, чей профиль мы смотрим
  def getProfilesData(user_id, followers, followees)
    if user_id.nil? then user_id = session[:user_id] end
    followers = followers ? followers.join(',') : ''
    followees = followees ? followees.join(',') : ''
    
    code = "
      var user_id = \"#{user_id}\";
      var app_friends = API.friends.getAppUsers();
      var uids = [#{followers}];
      uids = uids + app_friends;

      var fields = \"screen_name,photo,photo_medium,photo_big\";

      var user = API.users.get({ uids: user_id, fields: fields});
      var followers = API.users.get({ uids: uids, fields: fields});
      var followees = API.users.get({ uids: [#{followees}], fields: fields });

      return { user: user[0], followers: followers, followees: followees, app_friends: app_friends };"

    @app.execute code: code
  end
end