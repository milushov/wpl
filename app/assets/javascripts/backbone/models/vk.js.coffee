class Playlists.Models.Vk extends Backbone.Model

  defaults:
    base_url: 'https://api.vkontakte.ru/method/' # for makeUrl()
    url : 'http://playlists.dev:3000/' # (!) with slash
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
    if not type or not id then return false
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

  vote: (action, pid, tid, success, context) ->
    return if action isnt 'like' and action isnt 'hate' or not pid or not tid
    @ajax "#{@get('url')}api/playlists/#{pid}/tracks/#{tid}/#{action}", success, context, false, true, true

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

  saveNewPlaylist: (playlist_data, success, context) ->
    @ajax "#{@get("url")}api/playlists", success, context, playlist_data, true
  
  editPlaylist: (pid, new_tracks, success, context) ->
    console.log new_tracks
    @ajax "#{@get("url")}api/playlists/#{pid}/edit", success, context, tracks: new_tracks, true

  getComments: (pid, page = 0, per = 10, success, context) ->
    return if not pid
    url = "#{@get("url")}api/playlists/#{pid}/comments?page=#{page}&per=#{per}"
    @ajax url, success, context, false, true, 'get'

  saveNewComment: (pid, content, reply_to = null, success, context)  ->
    return if not pid or not content
    url = "#{@get("url")}api/playlists/#{pid}/comments/create"
    @ajax url, success, context, {content: content, reply_to: reply_to}, true

  updateComment: (pid, cid, new_content, success, context)  ->
    return if not pid or not cid or not new_content
    url = "#{@get("url")}api/playlists/#{pid}/comments/#{cid}/update"
    @ajax url, success, context, {content: new_content}, true

  deleteComment: (pid, cid, success, context)  ->
    return if not pid or not cid
    url = "#{@get("url")}api/playlists/#{pid}/comments/#{cid}/delete"
    @ajax url, success, context, false, true

  spamComment: (pid, cid, success, context)  ->
    return if not pid or not cid
    url = "#{@get("url")}api/playlists/#{pid}/comments/#{cid}/spam"
    @ajax url, success, context, false, true

  uploadImage: (file) ->
    unless file or not file.type.match /image.*/
      return notify 'Выберите изображение в формате jpeg, png, gif!'
      
    window.loading()
    fd = new FormData
    fd.append 'image', file
    fd.append 'key', imgur.key

    xhr = new XMLHttpRequest
    xhr.open "POST", imgur.api_url

    xhr.onload = ()->
      image_data = JSON.parse xhr.responseText
      App.new_playlist_view.trigger 'image_uploaded', image_data

    xhr.send fd

  getPlaylistsByTag: (tag)->
    $.get "#{@get('url')}api/playlists/tags/#{tag}", (data) ->
      unless data.error
        App.trigger 'playlists_by_tag_data_loaded', data
      else
        console.error data.error
    , 'json'

  getPlaylists: (type = 'popular', success, context)->
    url = "#{@get('url')}api/playlists/#{type}" # popular or last
    @ajax url, success, context, false, true, 'get'

  search: (query, success, context)->
    return false unless query
    url = "#{@get 'url'}api/playlists/search/#{query}"
    @ajax url, success, context, false, true, 'get'


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

  searchTracks: (track_name, offset = 0, success, context = null)->
    if !track_name then return false 
    params = 
      code:
       'var q = "' + track_name + '";
        var auto_complete = 1;
        var sort = 2;
        var lyrics = 1;
        var count = 5;
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
    @ajax @makeUrl('execute', params), success, context

  setCookies: (access_token, user_id, expires_in)->
    expires_in = expires_in/(24*60*60)
    $.cookie('access_token', access_token, { expires: expires_in });
    $.cookie('user_id', user_id, { expires: expires_in });

  getCookies: ->
    access_token: $.cookie('access_token')
    user_id: $.cookie('user_id')

  makeUrl: (method, params)->
    if not method then false else
      url =  @get('base_url') + method + '?access_token=' + @getCookies().access_token
      if not params then url else
        params_arr = []
        for key, val of params
          params_arr.push encodeURIComponent(key) + '=' + encodeURIComponent(val)
        if params_arr.length then url + '&' + params_arr.join('&') else url

  ajax: (url, success, context = false, _data = false, nojsonp = false, type = false) ->
    return false if not url?

    dataType = if nojsonp then 'json' else 'jsonp'
    crossDomain = if nojsonp then false else true
    data = if _data then _data else false
    type = if type then 'GET' else 'POST'

    req = $.ajax
      url: url
      type: type
      crossDomain: crossDomain
      data: data
      dataType: dataType
      context: context

    if not success?
      success = (data) =>
        console.log data.response, 'from App.vk.ajax()'
    
    req.done success

    req.fail (jqXHR, textStatus) =>
      console.error "Request failed(#{url}): #{textStatus}"
      # alert "Request failed(#{url}): #{textStatus}"

  rand: ->
    Math.random().toString(36).substr(-8)
