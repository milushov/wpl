class PlaylistsController < ApplicationController
	respond_to :json
	
	before_filter :check_auth

	# GET /playlists
	def index
		render json: Playlist.all.desc(:_id).limit(10), content_type: 'application/json'
	end

	# GET /playlists/url
	def show
		playlist = getPlaylist(params[:id])
		render json: playlist, content_type: 'application/json'
	end

	def not_found
		@error = { status: 0, description: "Playlist not found" }
		render json: @error, content_type: 'application/json'
	end

	# GET /playlists/1/edit
	def edit
		@playlist = Playlist.find(params[:id])
	end

	# POST /playlists
	def create
		@playlist = Playlist.new(params[:playlist])

		respond_to do |format|
			if @playlist.save
				format.html { redirect_to @playlist, notice: 'Playlist was successfully created.' }
				format.json { render json: @playlist, status: :created, location: @playlist }
			else
				format.html { render action: "new" }
				format.json { render json: @playlist.errors, status: :unprocessable_entity }
			end
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