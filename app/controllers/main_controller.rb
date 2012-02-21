class MainController < ApplicationController
	def index
		@playlists = Playlist.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracks }
    end
	end
end
