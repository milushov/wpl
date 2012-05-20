# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :app_init
  SHOW_FIELDS = %w{ id screen_name first_name last_name photo photo_big}
  APP_ID = 1111000
  APP_SECRET = '1111000key'
  REDIRECT_URI = 'http://playlists.dev:3000/auth'
  SETTINGS = 'notify,friends,photos,audio' # 1+2+4+8

  private

  def getAuthKey(user_id)
    Digest::MD5.hexdigest "#{APP_ID}_#{user_id}_#{APP_SECRET}"
  end

  # at the beginning we need to init VK module for requesting to vk.com api
  def app_init
    @vk = VK::Serverside.new app_id:APP_ID, app_secret: APP_SECRET    
    @vk.access_token = session[:access_token] if isAuth?
    #@vk.settings = SETTINGS
  end

  # check user authentication by cookies, and if alright - save them to session
  def isAuth?
    if cookies[:access_token] and cookies[:user_id] and cookies[:auth_key]
      auth_key, real_auth_key = cookies[:auth_key], getAuthKey(cookies[:user_id])
      if auth_key == real_auth_key
        session[:access_token] = cookies[:access_token]
        session[:user_id] = cookies[:user_id]
        session[:auth_key] = cookies[:auth_key]
        true
      end
    else
      false
    end
  end

  # get id of user and return full profile with all friends and playlists
  def getProfile(id)
    return false unless id
    return false unless user = User.any_of({screen_name: id}, {_id: id.to_i}).first

    # mini statisctics
    if user.me? session[:user_id]
      user.app_friends = @vk.friends.getAppUsers if user.last_visit < Time.now - 3.hour
      user.last_visit = Time.now
      user.visits_count = user.visits_count + 1
      user.save
    end   

    followers = user.all_followers_by_model('User').to_a
    followers_count = user.followers_count_by_model('User') || 0
    
    followees = user.all_followees_by_model('User').to_a
    followees_count = user.followees_count_by_model('User') || 0
    
    playlists_data = user.all_followees_by_model('Playlist')
    playlists_count = user.followees_count_by_model('Playlist') || 0
    
    playlists, playlists_followers_ids = [], []

    playlists_data.each do |playlist| # for loop for new scope
      fs = []
      # playlist.followers store following relations
      playlist.followers.to_a.each { |f| fs << f[:follower_id].to_i }

      playlists << {
        _id: playlist.id.to_s,
        url: playlist.url,
        image: playlist.image,
        name: playlist.name,
        description: playlist.description,
        tags: playlist.tags,
        tracks: playlist.tracks,
        followers_count: playlist.fferc,
        followers: fs
      }
      playlists_followers_ids += fs
    end

    playlists_followers = {};
    User.any_in(_id: playlists_followers_ids | user.app_friends).to_a.each do |follower|
      playlists_followers[follower[:_id]] = some_of follower
    end

    user.app_friends.each do |friend_id|
      followers.unshift playlists_followers[friend_id]
      followees.unshift playlists_followers[friend_id]
    end 

    playlists.each do |playlist|
      playlist[:followers].map! { |f| playlists_followers[f] }
    end
    
    profile = {}

    profile[:user] = some_of user
    profile[:followers] = followers.map { |f| some_of f } || [] # important to have empty arrays if no followers
    profile[:followees] = followees.map { |f| some_of f } || [] 
    profile[:playlists] = playlists || []
    profile[:user][:followers_count] = followers_count + user.app_friends.count
    profile[:user][:followees_count] = followees_count + user.app_friends.count
    profile[:user][:playlists_count] = playlists_count
    
    profile
  end

  def some_of from
    obj = {}
    SHOW_FIELDS.each do |field|
      field = field.to_sym
      obj[field] = from[field == :id ? :_id : field]
    end
    obj
  end

  # get 1 id of user whom page we need to get, 3 arrays of ids of his friends
  def getProfilesData(user_id, followers, followees, playlists_followers)
    user_id = session[:user_id] unless user_id
    followers = !followers.empty? ? followers.join(',') : ''
    followees = !followees.empty? ? followees.join(',') : ''
    playlists_followers = playlists_followers ? playlists_followers.join(',') : ''
    
    code = "
      var user_id = \"#{user_id}\";
      var app_friends = API.friends.getAppUsers();
      var uids = [#{followers}] + app_friends;

      var fields = \"screen_name,photo,photo_big\";

      var user = API.users.get({ uids: user_id, fields: fields});
      var followers = API.users.get({ uids: uids, fields: fields});
      var followees = API.users.get({ uids: [#{followees}], fields: fields });
      var playlists_followers = API.users.get({ uids: [#{playlists_followers}], fields: fields });

      return { 
        user: user[0],
        followers: followers,
        followees: followees,
        app_friends: app_friends,
        playlists_followers: playlists_followers
      };
    "

    @vk.execute code: code
  end

  # return full playlist by id
  def getPlaylist(url_or_id)
    return false unless url_or_id

    playlist = Playlist.any_of({url: url_or_id}, {_id: url_or_id}).first
    
    return false unless playlist
    
    followers = playlist.all_followers_by_model('User') 
       
    if followers
      # вытаскиваем id'шники
      followers_vk_ids = followers.map { |v| v[:vk_id] }

      # показываем только 15 фоловеров
      followers_vk_ids = followers_vk_ids[0...15] if followers_vk_ids.length > 15
      followers_vk_ids = followers_vk_ids ? followers_vk_ids.join(',') : ''

      code = "
        var uids = [#{followers_vk_ids}];
        var fields = \"screen_name,photo,photo_big\";
        var followers = API.users.get({ uids: uids, fields: fields});
        return followers;"

      followers_vk = @vk.execute code: code
      
      # сохраняем mongo'вские id'шники, вдруг понадобятся
      if followers_vk
        followers_vk.each do |fvk|
          temp = followers.select { |f| f[:vk_id] == fvk['uid'] }
          fvk[:id] = temp.empty? ? nil : temp[0][:_id]
        end
      else
        followers_vk = []
      end
    else
      followers_vk = []
    end

    {
      _id: playlist.id,
      name: playlist.name,
      url: playlist.url,
      image: playlist.image,
      description: playlist.description,
      tags: playlist.tags,
      created_at: playlist.created_at,
      updated_at: playlist.updated_at,
      tracks: playlist.tracks,
      followers_count: playlist.fferc,
      followers: followers_vk
    }    
  end

  # simple check authorization for actions which rendering json
  def check_auth
    error('auth fail', 'auth') unless isAuth?
  end
  
  # render error in json format
  def error(error = 'unknown error', auth_error = nil)
    http_code = auth_error ? 403 : 200
    render(
      json: { error: error },
      status: http_code
    ) and return
  end

  # spesial for alex.strigin :-)
  def format_fix
    unless %w{json html rss}.include? params[:format]
      params[:path] << ".#{params[:format]}" if params[:path]
      params[:id] << ".#{params[:format]}" if params[:id]
      params.delete 'format'
    end
  end
end