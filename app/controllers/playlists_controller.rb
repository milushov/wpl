# encoding: utf-8
class PlaylistsController < ApplicationController
  respond_to :json
  
  before_filter :check_auth

  # GET /playlists
  def index
    render json: Playlist.desc(:_id).limit(12)
  end

  def popular
    render json: Playlist.desc(:fferc).limit(12)
  end

  # GET /playlists/url
  def show
    if playlist = getPlaylist(params[:id])
      render json: playlist, content_type: 'application/json'
    else
      error("playlist #{params[:id]} not found")
    end
  end

  def follow
    if user = User.where(vk_id: session[:user_id].to_s).first
      unless playlist = Playlist.any_of({url: params[:id]}, {_id: params[:id]}).first
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

  def tags
    render json: Playlist.all_tags.map{ |p| p[:name] }
  end

  def playlistsByTag
    playlists = Playlist.tagged_with(params[:tag])
    render json: {tag: params[:tag], count: playlists.count, playlists: playlists.last(12)}
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # POST /playlists
  def create
    @playlist = Playlist.new(params[:playlist])

    if @playlist.save
      render json: @playlist, location: @playlist
    else
      error "#{params[:playlist][:name]} not created :-("
    end
  end

  # PUT /playlists/1
  def update
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        format.html { redirect_to @playlist, notice: 'Playlist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to playlists_url }
      format.json { head :no_content }
    end
  end
end