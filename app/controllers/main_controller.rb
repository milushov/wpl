class MainController < ApplicationController
	def index
		if cookies[:user_id]
			session[:vk_id] = cookies[:user_id]
			@auth_key = Digest::MD5.hexdigest( session[:vk_id] + 'roma_123_super_salt' )
		else
			@auth_key = 'not logged'
		end

		@playlists = Playlist.all
		

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracks }
    end
	end
end
