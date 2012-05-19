class TracksController < ApplicationController
  before_filter :check_auth, :prepare
  
  # GET api/playlists/:playlist_id/tracks/:audio_id
  def show
    render json: @track
  end

  # GET api/playlists/:playlist_id/tracks/:audio_id/like
  def like
    if @track.lovers.include? @uid
      error "you already like this track:#{@tid}"
    else
      vote :like and render json: @track
    end
  end

  # GET api/playlists/:playlist_id/tracks/:audio_id/hate
  def hate    
    if @track.haters.include? @uid
      error "you already hate this track:#{@tid}"
    else
      vote :hate and render json: @track
    end
  end

  private
    def prepare
      @pid = params[:playlist_id]
      @tid = params[:id]
      @uid = session[:user_id].to_i

      unless @playlist = Playlist.any_of({url: @pid}, {_id: @pid}).first
        error("playlist:#{@pid} not found") and return
      end
      
      unless @track = @playlist.tracks.any_of({audio_id: @tid}, {_id: @tid}).first
        error("playlist:#{@tid} not found") and return
      end

      unless @user = User.any_of({screen_name: @uid}, {vk_id: @uid}, {_id: @uid}).first
        error("user:#{@uid} not found") and return
      end
    end

    def vote(act)
      case act
        when :like
          @track.pull :haters, @uid and @track.inc :haters_count, -1 if @track.haters.include? @uid
          @track.push :lovers, @uid and @track.inc :lovers_count, 1
        when :hate
          @track.pull :lovers, @uid and @track.inc :lovers_count, -1 if @track.lovers.include? @uid
          @track.push :haters, @uid and @track.inc :haters_count, 1
        end
      @playlist.updated_at = @track.updated_at = Time.now.utc
    end
end
