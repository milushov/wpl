# encoding: utf-8
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

  def getProfile(id)
    return false unless id

    user = User.any_of({screen_name: id}, {vk_id: id}, {_id: id}).first
    
    return false unless user

    user_followers = {}; user.all_followers_by_model('User').to_a.each { |f| user_followers[f[:vk_id]] = f[:_id].to_s }
    user_followers_count = user.followers_count_by_model('User') || 0
    
    user_followees = {}; user.all_followees_by_model('User').to_a.each { |f| user_followees[f[:vk_id]] = f[:_id].to_s }
    user_followees_count = user.followees_count_by_model('User') || 0
    
    playlists_data = user.all_followees_by_model('Playlist')

    playlists, playlists_followers_ids = [], []

    playlists_data.each do |playlist|
      followers = []; playlist.followers.to_a.each { |f| followers << f[:follower_id].to_s }
      p = {
        _id: playlist.id.to_s,
        url: playlist.url,
        name: playlist.name,
        description: playlist.description,
        tags: playlist.tags,
        image: playlist.image,
        created_at: playlist.created_at,
        updated_at: playlist.updated_at,
        tracks: playlist.tracks,
        followers_count: playlist.fferc,
        followers: followers
      }
      playlists << p
      playlists_followers_ids += followers     
    end

    playlists_followers = {}; User.any_in(_id: playlists_followers_ids.uniq).to_a.each { |follower|
      playlists_followers[follower[:vk_id].to_s] = follower[:_id].to_s
    }
    
    playlists_count = user.followees_count_by_model('Playlist') || 0

    ufr_ids = []; user_followers.each_key { |key| ufr_ids << key }
    ufe_ids = []; user_followees.each_key { |key| ufe_ids << key }
    pf_ids = []; playlists_followers.each_key { |key| pf_ids << key }

    vk_data = getProfilesData(user[:vk_id], ufr_ids, ufe_ids, pf_ids)
    
    profile = {}
    profile[:user] = vk_data['user'];
    profile[:user][:followers_count] = user_followers_count + vk_data['app_friends'].count
    profile[:user][:followees_count] = user_followees_count + vk_data['app_friends'].count
    profile[:user][:playlists_count] = playlists_count
    
    if vk_data['playlists_followers']
      temp = {}; vk_data['playlists_followers'].each { |f| id = playlists_followers[f['uid'].to_s]; temp[id] = f }
      vk_data['playlists_followers'], temp = temp, nil
    end

    playlists.each do |playlist|
      followers = []; playlist[:followers].each { |f| followers << vk_data['playlists_followers'][f] }
      playlist[:followers] = followers
    end

    profile[:followers] = vk_data['followers'] || [] # важно чтобы были пустые массивы
    profile[:followees] = vk_data['followees'] || []
    profile[:playlists] = playlists || []
    
    profile
  end

  # принимает 2 массива id-шников vk и 1 id'шник юзера, чей профиль мы смотрим
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
    @app.execute code: code
  end


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

      followers_vk = @app.execute code: code
      
      # сохраняем mongo'вские id'шники, вдруг понадобятся
      if followers_vk
        followers_vk.each do |v|
          temp = followers.select { |val| v['uid'] == val[:vk_id] }
          v[:id] = temp.empty? ? nil : temp[0][:_id]
        end
      else
        followers_vk = []
      end
    else
      followers_vk = []
    end

    p = {
      _id: playlist.id,
      name: playlist.name,
      image: playlist.image,
      description: playlist.description,
      tags: playlist.tags,
      url: playlist.url,
      created_at: playlist.created_at,
      updated_at: playlist.updated_at,
      tracks: playlist.tracks,
      followers_count: playlist.fferc,
      followers: followers_vk
    }    
  end

  # simple check authorization to app
  def check_auth
    error('auth fail', 'auth') unless isAuth?
  end

  def error(error = 'unknown error', auth_error = nil)
    http_code = auth_error ? 403 : 200
    render(
      json: { error: error },
      status: http_code
    ) and return
  end
end