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

  def getProfile(id = nil)
    return false unless id

    user_s = {} # user source
    user_s[:info] = User.any_of({screen_name: id}, {vk_id: id}, {_id: id}).first
    
    return false if user_s[:info].nil?

    user_s[:followers] = user_s[:info].all_followers_by_model('User')
    user_s[:followers_count] = user_s[:info].followers_count_by_model('User')
    
    user_s[:followees] = user_s[:info].all_followees_by_model('User')
    user_s[:followees_count] = user_s[:info].followees_count_by_model('User')
    
    user_s[:playlists] = user_s[:info].all_followees_by_model('Playlist')   
    user_s[:playlists_count] = user_s[:info].followees_count_by_model('Playlist')

    user_vk_id = user_s[:info][:vk_id]

    # вытаскиваем id'шники
    followers_vk_ids = []
    user_s[:followers].each{ |v| followers_vk_ids << v[:vk_id] }

    followees_vk_ids = []
    user_s[:followees].each{ |v| followees_vk_ids << v[:vk_id] }

    user_vk_profile = getProfilesData user_vk_id, followers_vk_ids, followees_vk_ids
    #user_vk_profile = getProfilesData 788157, [1,2], [1,788157]

    # конечный hash
    user_profile = {}
    user_profile[:user] = user_vk_profile['user']
    user_profile[:user][:id] = user_s[:info][:_id]
    user_profile[:user][:followers_count]= user_s[:followers_count] + user_vk_profile['app_friends'].count
    user_profile[:user][:followees_count]= user_s[:followees_count] + user_vk_profile['app_friends'].count
    user_profile[:user][:playlists_count]= user_s[:playlists_count]
    
    # сохраняем mongo'вские id'шники, вдруг понадобятся
    if user_vk_profile['followers']
      user_vk_profile['followers'].each do |v|
        temp = user_s[:followers].select { |val| v['uid'] == val[:vk_id] }
        v[:id] = temp.empty? ? nil : temp[0][:_id]
      end
    end

    if user_vk_profile['followees']
      user_vk_profile['followees'].each do |v|
        temp = user_s[:followees].select { |val| v['uid'] == val[:vk_id] }
        v[:id] = temp.empty? ? nil : temp[0][:_id]
      end
    end
    
    user_profile[:followers] = user_vk_profile['followers'] || {}
    user_profile[:followees] = user_vk_profile['followees'] || {}
    user_profile[:playlists] = user_s[:playlists] || {}
    user_profile[:status] = true

    user_profile
  end

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

  # simple check authorization to app
  def check_auth
    unless isAuth?
      error = { status: false, description: 'auth fail' }
      render json: error, content_type: 'application/json' and return
    end
  end
end