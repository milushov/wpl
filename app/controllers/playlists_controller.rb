# encoding: utf-8
class PlaylistsController < ApplicationController
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
    playlist = JSON.parse params['playlist']

    @playlist = Playlist.new(playlist)
    
    if @playlist.save
      user = User.where(vk_id: session[:user_id].to_s).first
      user.follow @playlist
      render json: {status: true, id: @playlist[:url]}, location: @playlist
    else
      error "#{playlist['name']} not created :-("
    end
  end

  # GET /playlists/test/follow
  def follow
    if user = User.where(vk_id: session[:user_id].to_s).first
      unless playlist = Playlist.any_of({url: params[:id]}, {_id: params[:id]}).first
        # playlist = Playlist.find2 params[:id]
        error 'playlist not found'
        return
      end
      status = user.follow(playlist)
      if status.nil?
        render json: {status: true, id: params[:id]}
      elsif status == false
        error "Вы уже подписаны на этот [#{params[:id]}] плейлист."
      else
        error 'oO'
      end
    end
  end

  # GET /playlists/test/unfollow
  def unfollow
    if user = User.where(vk_id: session[:user_id].to_s).first
      unless playlist = Playlist.any_of({url: params[:id]}, {_id: params[:id]}).first
        error 'playlist not found'
        return
      end
      status = user.unfollow(playlist)
      if status.nil?
        render json: {status: true, id: params[:id]}
      elsif status == false
        error "Вы уже отписалить от этого плейлиста [#{params[:id]}]."
      else
        error 'oO'
      end
    end
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
      fs = []
      playlist.followers.to_a.each { |f| fs << f[:follower_id] }
      playlists << {
        _id: playlist.id.to_s,
        url: playlist.url,
        name: playlist.name,
        description: playlist.description,
        tags: playlist.tags,
        image: playlist.image,
        tracks: playlist.tracks,
        followers_count: playlist.fferc,
        followers: fs
      }
      playlists_followers_ids += fs
    end

    playlists_followers = {};

    User.any_in(_id: playlists_followers_ids.uniq).to_a.each do |follower|
      playlists_followers[follower[:_id]] = follower
    end

    playlists.each do |playlist|
      playlist[:followers].map! { |id| some_of playlists_followers[id] }
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
end