# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :app_init, :check_abuse

  COUNT_FRIENDS = 0...15
  MAX_REQUERS_PER_SECOND = 2

  APP_ID = ENV['USER'] ? 2999165 : 1111000 # development and production app id
  APP_SECRET = '1111000key'
  SETTINGS = 'notify,friends,audio'
  DEV_URL = 'http://playlists.dev:3000/'
  PROD_URL = 'http://wpl.me/'
  APP_URL = ENV['USER'] ? DEV_URL : PROD_URL
  REDIRECT_URI = "#{APP_URL}auth"
  DEBUG = ENV['USER'] || 1 ? true : false # temprary

private
  
  def getAuthKey user_id
    Digest::MD5.hexdigest "#{APP_ID}_#{user_id}_#{APP_SECRET}"
  end

  # at the beginning we need to init VK module for requesting to vk.com api
  def app_init
    @vk = VK::Serverside.new app_id:APP_ID, app_secret: APP_SECRET#, settings: SETTINGS
    @vk.settings = SETTINGS
    @vk.access_token = session[:access_token] if isAuth?
  end

  # check user authentication by cookies, and if alright - save them to session
  def isAuth?
    if cookies[:access_token] and cookies[:user_id] and cookies[:auth_key]
      auth_key = cookies[:auth_key]
      real_auth_key = getAuthKey cookies[:user_id]
      if auth_key == real_auth_key
        session[:access_token] = cookies[:access_token]
        session[:user_id] = cookies[:user_id]
        session[:auth_key] = cookies[:auth_key]
        session[:abuse] ||= []
        true
      else
        false
      end
    else
      false
    end
  end

  # get id of user and return full profile with all friends and playlists
  def getProfile(id)
    return false unless id
    return false unless user = User.find2(id)

    if user.ban
      session['ban'] = user.unban_date
      return -1 
    end
    
    # if error occurs when we make request to vk.com
    resp = mini_statistics user
    if resp.respond_to?(:kind_of?)
      return resp if resp.kind_of? Numeric
    end
      
    followers = user.all_followers_by_model('User').to_a
    followers_count = user.followers_count_by_model('User') || 0
    
    followees = user.all_followees_by_model('User').to_a
    followees_count = user.followees_count_by_model('User') || 0
    
    playlists_data = user.all_followees_by_model('Playlist')
    playlists_count = user.followees_count_by_model('Playlist') || 0
    
    playlists, playlists_followers_ids = [], []

    playlists_data.each do |playlist|
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
        track[:real_lovers_count] = track.lovers.count
        track[:real_haters_count] = track.haters.count
        track[:lovers].map! do |id|
          playlists_followers[id].show without: %w{ photo_big last_name }
        end
      end
    end
    
    profile = {}

    profile[:user] = user.show
    profile[:followers] = followers.reverse[COUNT_FRIENDS].delete_if{ |x| x.nil? }[COUNT_FRIENDS].map { |f| f.show } || []
    profile[:followees] = followees.reverse[COUNT_FRIENDS].delete_if{ |x| x.nil? }.map { |f| f.show } || [] 
    profile[:playlists] = playlists || []
    profile[:user][:followers_count] = followers_count + user.app_friends.count
    profile[:user][:followees_count] = followees_count + user.app_friends.count
    profile[:user][:playlists_count] = playlists_count

    profile
  end

  def mini_statistics user
    if user.me? session[:user_id]
      begin
        user.app_friends = @vk.friends.getAppUsers if user.last_visit < Time.now - 3.hour
      rescue Exception => ex
        # 5: User authorization failed: access_token have heen expired
        return ex.error_code
      end
      user.last_visit = Time.now
      user.visits_count = user.visits_count + 1
      user.save
    end
  end

  # return full playlist by id
  def getPlaylist(id)
    return false unless id
    return false unless playlist = Playlist.find2(id)
    
    followers = playlist.all_followers_by_model('User')  || []
    followers = followers[COUNT_FRIENDS]

    lovers_ids = []
    playlist.tracks.map! do |track|
      track[:real_lovers_count] = track.lovers.count
      track[:real_haters_count] = track.haters.count
      track[:lovers] = track[:lovers].reverse[0...5]
      lovers_ids |= track[:lovers]

      track
    end

    # we don't need to show banned tracks
    playlist.tracks.keep_if{ |track| not track.haters.include?(session[:user_id].to_i) }
    
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

  # simple check authorization for actions which render json
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

  # if you make abuse request 3 in a row times, then you will suck
  def check_abuse
    return unless session[:abuse]
    abuse_time = 1.0/MAX_REQUERS_PER_SECOND
    if session[:abuse].size >= 4
      session[:abuse].shift and session[:abuse].push Time.now.to_f
      times = []
      3.downto(1) { |i| times << session[:abuse][i] - session[:abuse][i-1] }
      return error "abuse", 403 if times.max < abuse_time
    else
      session[:abuse].push Time.now.to_f
    end
  end
end
