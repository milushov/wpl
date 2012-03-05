class Playlists.Models.Vk extends Backbone.Model
	defaults:
		base_url: 'https://api.vkontakte.ru/method/',
		appId : 1111000
		url : "http://playlists.dev:3000/"
		settings : 'notify,friends,audio'#1+2+8+1024+2048
		user_id : 0
		auth_status : false

	
	initialize:  ->
		console.log 'Vk model created'
		@auth()
		#@getProfile [1,111,23234], [1,2], 1, (data)-> console.log data.response, 'getProfile()'
		#@getPlaylistData ['1_115553105', '1_138952258', '1_135538161'], (data)-> console.log data.response, 'getPlaylistData()'

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
				@set auth_status: true
			else
				location.href = "http://oauth.vkontakte.ru/authorize?client_id=#{ @get 'appId' }&scope=#{ @get 'settings' }&redirect_uri=#{ @get 'url' }&response_type=token"
				return false
		else
			@set auth_status:true


	# принимает 2 массива id-шников vk и 1 число
	getProfile: (followers, following, user_id, success)->
		if !followers then followers = '' else followers.join ','
		if !following then following = '' else following.join ','
		if !user_id then user_id = @getCookies().user_id

		params = 
			code:
			 'var user_id = ' + user_id + ';
				var fields = "screen_name,photo,photo_medium,photo_big";
				var app_friends = API.friends.getAppUsers();
				var uids = [' + followers + '] + app_friends;
				var user = API.users.get({ uids: user_id, fields: fields});
				var followers = API.users.get({ uids: uids, fields: fields});
				var following = API.users.get({ uids: [' + following + '], fields: fields });
				return { user: user, followers: followers, following: following };'

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

