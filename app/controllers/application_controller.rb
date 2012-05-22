# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :app_init, :check_abuse

  COUNT_FRIENDS = 0...15
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
        session[:abuse] ||= []
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
    session['ban'] = user.unban_date and return -1 if user.ban
    
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
      fs, ts = [], []
      # playlist.followers store following relations
      playlist.followers.to_a.each { |f| fs << f[:follower_id].to_i }

      playlist.tracks.map! do |track|
        track[:lovers] = track[:lovers].reverse[0...5]
        ts += track[:lovers]
        track
      end

      playlists << {
        _id: playlist.id.to_s,
        url: playlist.url,
        image: playlist.image,
        name: playlist.name,
        description: playlist.description,
        tags: playlist.tags,
        tracks: playlist.tracks,
        followers_count: playlist.fferc,
        followers: fs.reverse
      }
      playlists_followers_ids += fs + ts
    end

    playlists_followers = User.getByIds playlists_followers_ids | user.app_friends

    user.app_friends.each do |friend_id|
      followers.unshift playlists_followers[friend_id]
      followees.unshift playlists_followers[friend_id]
    end 

    playlists.each do |playlist|
      playlist[:followers] = playlist[:followers][COUNT_FRIENDS].map { |id| playlists_followers[id] }
      playlist[:tracks].each do |track|
        track[:lovers].map! do |id|
          playlists_followers[id].show without: %w{ photo_big last_name }
        end
      end
    end
    
    profile = {}

    profile[:user] = user.show
    profile[:followers] = followers.reverse[COUNT_FRIENDS].map { |f| f.show } || []
    profile[:followees] = followees.reverse[COUNT_FRIENDS].map { |f| f.show } || [] 
    profile[:playlists] = playlists || []
    profile[:user][:followers_count] = followers_count + user.app_friends.count
    profile[:user][:followees_count] = followees_count + user.app_friends.count
    profile[:user][:playlists_count] = playlists_count

    profile
  end

  # return full playlist by id
  def getPlaylist(id)
    return false unless id
    return false unless playlist = Playlist.any_of({url: id}, {_id: id}).first
    
    followers = playlist.all_followers_by_model('User')  || []
    followers = followers[COUNT_FRIENDS]

    lovers_ids = []
    playlist.tracks.map! do |track|
      track[:lovers] = track[:lovers].reverse[0...5]
      lovers_ids |= track[:lovers]
      track
    end
    
    lovers = User.getByIds lovers_ids

    playlist.tracks.each do |track|
      track.lovers.map! { |id| lovers[id].show without: %w{ last_name photo_big } }
    end

    {
      _id: playlist.id,
      name: playlist.name,
      url: playlist.url,
      image: playlist.image,
      description: playlist.description,
      tags: playlist.tags,
      tracks: playlist.tracks,
      followers_count: playlist.fferc,
      followers: followers
    }    
  end

  # simple check authorization for actions which rendering json
  def check_auth
    error('auth fail', 401) unless isAuth?
    error("ban up to #{session['ban']}", :auth) if session['ban']
  end
  
  # render error in json format
  def error(error = 'unknown error', http_code = nil)
    http_code = 200 unless http_code
    return render json: { error: error }, status: http_code
  end

  # spesial for alex.strigin :-)
  def format_fix
    unless %w{json html rss}.include? params[:format]
      params[:path] << ".#{params[:format]}" if params[:path]
      params[:id] << ".#{params[:format]}" if params[:id]
      params.delete 'format'
    end
  end

  def check_abuse
    return unless session[:abuse]
    if session[:abuse].size >= 3
      session[:abuse].shift and session[:abuse].push Time.now.to_f
      last_time = session[:abuse][2] - session[:abuse][1]
      if last_time < 1.0/2
        session[:abuse] = []
        return error "abuse", 403
      end
    else
      session[:abuse].push Time.now.to_f
    end
  end
end