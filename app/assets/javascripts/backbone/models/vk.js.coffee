class Playlists.Models.Vk extends Backbone.Model
	defaults:
		base_url: 'https://api.vkontakte.ru/method/',
		appId : 2845993
		url : "http://playlists.dev:3000/"
		settings : 1+2+8+1024+2048 #'notify,friends,audio'
		user_id : null
		access_token : null
		auth_status : false

	
	initialize:  ->
		console.log 'Vk model created'
		#@getProfilesData [1,111,23234], [1,2], 1, (data)-> console.log data.response, 'getProfile()'
		#@getPlaylistData ['1_115553105', '1_138952258', '1_135538161'], (data)-> console.log data.response, 'getPlaylistData()'

	isAuth: ->
		if @getCookies().access_token and @getCookies().user_id
			true
		else
			false


	# главная функция авторизации
	auth: ->
		if @isAuth() then true else
			if @saveNewAccessToken() then true else
				location.href = "http://api.vk.com/oauth/authorize?client_id=#{ @get 'appId' }&scope=#{ @get 'settings' }&redirect_uri=#{ @get('url') + 'access_token' }&response_type=token"
				false

	saveNewAccessToken: ()->
		cur_url = $.url().fparam()

		access_token = cur_url.access_token
		expires_in = cur_url.expires_in
		user_id = cur_url.user_id

		if !(access_token and expires_in and user_id) then false else
			@setCookies access_token, expires_in, user_id
			@set auth_status: true
			true

	# получаем инфу о пользователе
	getProfile: (id)->
		$.get @get('url') + "api/users/#{id}", (data)=>
			if data and data.status == true
				# Ужас! Что я творю!? Не могу придумать лучше :( 
				# Нужно это для "сохранения данных между асинхроннми функциями"
				App.temp.user_data = data
				# вытаскиваем id'шники
				followers = for key, follower of data.followers
					follower.vk_id
				followees = for key, followee of data.followees
					followee.vk_id
				
				user_id = data.info.vk_id
				
				@getProfilesData followers, followees, user_id, (data)=>
					if data.error
						alert 'Упс! Што-то пошло не так.. ' + data.error.error_msg + ' ' + data.error.error_code
						console.log 'request_params:', data.error.request_params
					else if data.response
						App.temp.user = 
							user: data.response.user[0]
							followers: data.response.followers
							followees: data.response.followees
							followers_count: App.temp.user_data.followers_count # на случай, когда дохрена фоловеров
							followees_count: App.temp.user_data.followees_count
							playlists: App.temp.user_data.playlists
						delete App.temp.user_data
						App.trigger 'user_data_loaded'
						# теперь нужно как-то отправить событие о том, что данные загрузились

			else
				return false
		, 'json'

	# принимает 2 массива id-шников vk и 1 число
	getProfilesData: (followers, followees, user_id, success)->
		if !followers then followers = '' else followers.join ','
		if !followees then followees = '' else followees.join ','
		if !user_id then user_id = @getCookies().user_id

		params = 
			code:
			 'var user_id = ' + user_id + ';
				var fields = "screen_name,photo,photo_medium,photo_big";
				var app_friends = API.friends.getAppUsers();
				var uids = [' + followers + '] + app_friends;
				var user = API.users.get({ uids: user_id, fields: fields});
				var followers = API.users.get({ uids: uids, fields: fields});
				var followees = API.users.get({ uids: [' + followees + '], fields: fields });
				return { user: user, followers: followers, followees: followees };'

		@ajax @makeUrl('execute', params), success


	getPlaylistData: (tracks, success)->
		if !tracks then false else tracks = tracks.join ','
		params = 
			audios: tracks
		@ajax @makeUrl('audio.getById', params), success

	getTrackData: (id, success)->
		if !id then return false
		params = 
			audios: id
		@ajax @makeUrl('audio.getById', params), success

	getThreeTrackData: (ids, success)->
		if !ids then return false
		for key, val of ids
			ids[key] = '"' + val + '"'
		params = 
			code:
			 'var audios = [' + ids.join(',') + '];
				var prev = API.audio.getById({ audios: audios[0] });
				var current = API.audio.getById({ audios: audios[1] });
				var next = API.audio.getById({ audios: audios[2] });
				return { prev: prev[0], current: current[0], next: next[0] };'
		@ajax @makeUrl('execute', params), success

	searchTrack: (track_name, offset = 0, success)->
		if !track_name then return false 
		params = 
			code:
			 'var q = "' + track_name + '";
				var auto_complete = 1;
				var sort = 2;
				var lyrics = 1;
				var count = 10;
				var offset = ' + offset + ';
				var tracks = API.audio.search( {q: q, auto_complete: auto_complete, sort: sort, lyrics: lyrics, count: count, offset: offset} );
				if( tracks[0] == 0 ) {
					lyrics = 0;
					tracks = API.audio.search( {q: q, auto_complete: auto_complete, sort: sort, lyrics: lyrics, count: count, offset: offset} );
					if( tracks[0] > 0 ) {
						return { tracks: tracks };
					} else {
						return { tracks: false };
					}
				} else {
					return { tracks: tracks };
				}'
		@ajax @makeUrl('execute', params), success



	setCookies: (access_token, expires_in, user_id)->
		expires_in = expires_in/(24*60*60)
		$.cookie('access_token', access_token, { expires: expires_in });
		$.cookie('user_id', user_id, { expires: expires_in });

	
	getCookies: ->
		access_token: $.cookie('access_token')
		user_id: $.cookie('user_id')

	makeUrl: (method, params)->
		if !method then false	else
			url =  @get('base_url') + method + '?access_token=' + @getCookies().access_token
			if !params then url else
				params_arr = []
				for key, val of params
					params_arr.push encodeURIComponent(key) + '=' + encodeURIComponent(val)
				if params_arr.length then url  + '&' + params_arr.join('&') else url


	ajax: (url, success) ->
		if !url then false
		req = $.ajax
			url: url
			type: "POST"
			crossDomain: true
			dataType: "jsonp"

		if !success then success = (data)-> console.log data.response, 'ajax()'
		req.done success

		req.fail (jqXHR, textStatus) ->
			alert( "Request failed("+url+"): " + textStatus )  


	rand: ->
		Math.random().toString(36).substr(-8)

