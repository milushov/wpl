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
    console.log 'Vk model created'
    @set auth_status: @isAuth()

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

  getProfile: (id)->
    $.get "#{@get('url')}api/users/#{id}", (data)=>
      if data && !data.error
        App.trigger 'user_data_loaded', data
      else
        console.error data.error
        false
    , 'json'

  getPlaylist: (id)->
    $.get "#{@get('url')}api/playlists/#{id}", (data)=>
      if data && !data.error
        playlist = new Playlists.Models.Playlist(data)
        App.trigger 'playlist_loaded', playlist
        console.log "Playlists.Models.Vk getPlaylist()", playlist
      else
        console.error data.error
        false
    , 'json'

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

