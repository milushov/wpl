# encoding: utf-8
class PlaylistsController < ApplicationController
  before_filter :check_auth
  PER_PAGE = 12
  respond_to :json
  
  before_filter :check_auth

  # GET /playlists
  def index
    render json: Playlist.desc(:_id).limit(PER_PAGE)
  end

  def popular
    render json: Playlist.desc(:fferc).limit(PER_PAGE)
  end

  def last
    render json: Playlist.desc(:fferc).limit(PER_PAGE)
  end

  # GET /playlists/url
  def show
    if playlist = getPlaylist(params[:id])
      render json: playlist, content_type: 'application/json'
    else
      error("playlist #{params[:id]} not found")
    end
  end

  # POST /playlists
  def create
    playlist = pick JSON.parse(params[:playlist]), :name, :url, :image, :description, :tags, :tracks
    if playlist[:image]
      playlist[:image_small] = playlist[:image]['image_small'] || nil
      playlist[:image] = playlist[:image]['image'] || nil
    end
    playlist[:creator] = session[:user_id]

    @playlist = Playlist.new playlist
    
    if status = @playlist.save
      user = User.find session[:user_id].to_i
      user.follow @playlist
      render json: {status: status, id: @playlist[:url]}, location: @playlist
    else
      return error 'Плейлист не создан, т.к. одно из полей было заполненно неверно.'
    end
  end

  # GET /playlists/test/follow
  def follow
    do_follow
  end

  # GET /playlists/test/unfollow
  def unfollow
    do_follow :undo
  end

  # GET /playlists/tags
  def tags
    render json: Playlist.all_tags.map{ |p| p[:name] }
  end

  # GET /playlists/tags/sport
  def playlistsByTag
    limit = (params[:limit] ? (3..3*10).include?(params[:limit].to_i) : false) ? params[:limit].to_i : PER_PAGE
    skip = (params[:skip] ? (1..15).include?(params[:skip].to_i) : false) ? params[:skip].to_i*PER_PAGE : 0 
    
    playlists_data = Playlist.tagged_with(params[:tag].to_s, skip, limit)

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

    playlists_followers = User.getByIds playlists_followers_ids

    playlists.each do |playlist|
      playlist[:followers] = playlist[:followers][COUNT_FRIENDS].map { |id| playlists_followers[id] }
      playlist[:tracks].each do |track|
        track[:lovers].map! do |id|
          playlists_followers[id].show without: %w{ photo_big last_name }
        end
      end
    end

    render json: {
      tag: params[:tag].to_s,
      count: playlists.count,
      playlists: playlists
    }
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # PUT /playlists/1
  def update
    # @playlist = Playlist.find(params[:id])
  end

  # DELETE /playlists/1
  def destroy
    # @playlist = Playlist.find(params[:id])
    # @playlist.destroy
  end

private
  def pick(hash, *keys)
    filtered = {}
    hash.each do |key, value| 
      filtered[key.to_sym] = value if keys.include?(key.to_sym) 
    end
    filtered
  end

  def do_follow undo = nil
    if user = User.find(session[:user_id].to_i)
      unless playlist = Playlist.any_of({url: params[:id]}, {_id: params[:id]}).first
        return error "playlist:#{params[:id]} not found"
      end
      
      status = !undo ? user.follow(playlist) : user.unfollow(playlist)
      
      if status.nil?
         render json: {status: true, id: params[:id]}
      elsif status == false
        error "Вы уже #{ !undo ? 'подписаны на этот' : 'отписаны от этого'} плейлиста:#{params[:id]}."
      else
        error 'o_O'
      end
    end
  end
end