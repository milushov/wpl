class Playlists.Models.Vk extends Backbone.Model
	defaults:
		appId: 1111000
		url: "http://" + "playlists.dev:3000/"
		settings: 1+2+8+1024+2048
		user_id: 0
		auth: false
		qwe: @appId

	initializer:  ->
		console.log 'Vk model created'
	
	isAuth: ->
		if @auth == true
			return true
	
	init: ->
		"http://oauth.vkontakte.ru/authorize?client_id=#{@appId}&scope=#{ @settings }&redirect_uri=#{ @url }&response_type=token"
		#VK.init(apiId: @appId);
	qwe: ->
		@appId
		
