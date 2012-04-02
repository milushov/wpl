class PlaylistsController < ApplicationController
	respond_to :json
	

	# GET /playlists
	def index
		#respond_with(Playlist.all)
		render json: Playlist.all, content_type: 'application/json'
	end

	# GET /playlists/url
	def show
		url_or_id = params[:id]
		@playlist = Playlist.any_of({url: url_or_id}, {_id: url_or_id}).first
		# if !@playlist.nil?
		# 	@playlist.instance_eval do |x|
		# 		@followers = x.all_followers
		# 	end
		# else
		# 	redirect_to action: :not_found
		# 	return
		# end
		pl = Hash.new(0)
		#pl[:playlist] = @playlist
		pl[:a] = @playlist.tracks
		render json: pl.to_json, content_type: 'application/json'
	end

	def not_found
		@error = { status: 0, description: "Playlist not found" }
		render json: @error, content_type: 'application/json'
	end

	# GET /playlists/new
	def new
		@playlist = Playlist.new

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @playlist }
		end
	end

	# GET /playlists/1/edit
	def edit
		@playlist = Playlist.find(params[:id])
	end

	# POST /playlists
	# POST /playlists.json
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
	# PUT /playlists/1.json
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
	# DELETE /playlists/1.json
	def destroy
		@playlist = Playlist.find(params[:id])
		@playlist.destroy

		respond_to do |format|
			format.html { redirect_to playlists_url }
			format.json { head :no_content }
		end
	end
end
