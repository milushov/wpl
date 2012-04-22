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
    playlists_data = Playlist.tagged_with(params[:tag])

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

    pf_ids = []; playlists_followers.each_key { |key| pf_ids << key }

    pf_ids = !pf_ids.empty? ? pf_ids.join(',') : ''
    
    code = "
      var fields = \"screen_name,photo,photo_big\";
      var playlists_followers = API.users.get({ uids: [#{pf_ids}], fields: fields });
      return {
        playlists_followers: playlists_followers
      };
    "
    
    vk_data = @app.execute code: code

    if vk_data['playlists_followers']
      temp = {}; vk_data['playlists_followers'].each { |f| id = playlists_followers[f['uid'].to_s]; temp[id] = f }
      vk_data['playlists_followers'], temp = temp, nil
    end

    playlists.each do |playlist|
      followers = []; playlist[:followers].each { |f| followers << vk_data['playlists_followers'][f] }
      playlist[:followers] = followers
    end

    render json: {tag: params[:tag], count: playlists.count, playlists: playlists.last(12)}
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
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