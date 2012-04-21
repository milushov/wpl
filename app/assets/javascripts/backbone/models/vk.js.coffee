class Playlists.Models.Vk extends Backbone.Model
  defaults:
    base_url: 'https://api.vkontakte.ru/method/',
    appId : 1111000
    url : 'http://playlists.dev:3000/'
    settings : 'notify,friends,photos,audio' # 1+2+4+8
    user_id : null
    access_token : null
    auth_status : false

  
  initialize:  ->
    console.log 'Models.Vk initialize()'
    @set auth_status: @isAuth()

  isAuth: ->
    if @getCookies().access_token and @getCookies().user_id
      true
    else
      false

  getProfile: (id)->
    if not id
      return false
    $.get "#{@get('url')}api/users/#{id}", (data)->
      if data and not data.error
        l data, 'from App.vk.getProfile()'
        App.trigger 'user_data_loaded', data
        true
      else
        console.error data.error
        #history.back()
        #alert data.error
        App.notFound()
    , 'json'

  follow: (type, id, undo)->
    if not type or not id then eturn false
    if type != 'user' and type != 'playlist' then return false

    url = @get('url')
    action = unless undo then 'follow' else 'unfollow'

    $.get "#{url}api/#{type}s/#{id}/#{action}", (data)->
      if data and not data.error
        if type == 'user'
          if action == 'follow' 
            App.trigger 'user_follow', data  
          else
            App.trigger 'user_unfollow', data  
        else if type == 'playlist'
          if action == 'follow'
            App.trigger 'playlist_follow', data
          else
            App.trigger 'playlist_unfollow', data
        true
      else
        console.error data.error
        #history.back()
        #alert data.error
        #App.notFound()
        false
    , 'json'

  getPlaylist: (id)->
    $.get "#{@get('url')}api/playlists/#{id}", (data)->
      if data && !data.error
        playlist = new Playlists.Models.Playlist(data)
        App.trigger 'playlist_loaded', playlist
        console.log "Playlists.Models.Vk getPlaylist()", playlist
      else
        console.error data.error
        App.notFound()
    , 'json'

  getPlaylistsByTag: (tag)->
    $.get "#{@get('url')}api/playlists/tags/#{tag}", (data)->
      if data && !data.error
        console.log "Playlists.Models.Vk getPlaylistsByTag()", data
        App.trigger 'playlists_by_tag_data_loaded', data
      else
        console.error data.error
        App.notFound()
    , 'json'

  getTrackData: (id, success, context)->
    if !id then return false
    params = 
      audios: id
    @ajax @makeUrl('audio.getById', params), success, context

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

  searchTracks: (track_name, offset = 0, success)->
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
    if !method then false else
      url =  @get('base_url') + method + '?access_token=' + @getCookies().access_token
      if !params then url else
        params_arr = []
        for key, val of params
          params_arr.push encodeURIComponent(key) + '=' + encodeURIComponent(val)
        if params_arr.length then url  + '&' + params_arr.join('&') else url

  ajax: (url, success, context = false) ->
    if !url then false
    req = $.ajax
      url: url
      type: "POST"
      crossDomain: true
      dataType: "jsonp"
      context: context

    if !success then success = (data)=> console.log data.response, 'ajax()'
    req.done success

    req.fail (jqXHR, textStatus) =>
      alert( "Request failed("+url+"): " + textStatus )  

  rand: ->
    Math.random().toString(36).substr(-8)

