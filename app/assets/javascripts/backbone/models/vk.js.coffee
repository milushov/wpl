class Playlists.Models.Vk extends Backbone.Model
	defaults:
		appId : 1111000
		url : "http://playlists.dev:3000/"
		settings : 1+2+8+1024+2048
		user_id : 0
		auth_status : false

	
	initialize:  ->
		console.log 'Vk model created'
		@auth()

	isAuth: ->
		@get('auth_status') == true

	# главная функция авторизации
	auth: ->
		if !(@getCookies().access_token or @getCookies().user_id)
			cur_url = $.url().fparam()
			access_token = cur_url.access_token
			expires_in = cur_url.expires_in
			user_id = cur_url.user_id

			if (access_token and expires_in and user_id)
				@setCookies access_token, expires_in, user_id
				@set auth_status:true
			else
				location.href = "http://oauth.vkontakte.ru/authorize?client_id=#{ @get 'appId' }&scope=#{ @get 'settings' }&redirect_uri=#{ @get 'url' }&response_type=token"
				return false
		else
			@set auth_status:true

	setCookies: (access_token, expires_in, user_id)->
		expires_in = expires_in/(24*60*60)
		$.cookie('access_token', access_token, { expires: expires_in });
		$.cookie('user_id', user_id, { expires: expires_in });
	
	getCookies: ->
		access_token: $.cookie('access_token')
		user_id: $.cookie('user_id')


