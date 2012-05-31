Playlists.Models.Player ||= {}

class Playlists.Models.Player extends Backbone.Model

  defaults:
    state: 'pause'
    cur_track: null
    duration_mode: 'pos' # or 'neg'
    volume: 100

  initialize: (opts)->
    console.log 'Player model created'
    @fail_url = 'http://vk.com/mp3/bb2.mp3'    
    @set duration_mode: opts.duration_mode
    @set volume: opts.volume

  reset: ->
    soundManager.reboot()

  play: (track = null) ->
    if track
      audio_id = track.get 'audio_id'
      playlist_id = track.get 'playlist_id'
    else
      @playlist = App.playlists.getByUrl curUrl()[1..]
      audio_id = @playlist.tracks.at(0).get 'audio_id'
      playlist_id = @playlist.get '_id'

    if not @playlist? or @playlist?.get('_id') isnt playlist_id
      @playlist = App.playlists.getById playlist_id

    if cur_track = @get('cur_track') # если пытаемя задействовать текущий трек
      if cur_track.smid() is "#{playlist_id}:#{audio_id}"
        @togglePause()
        return

    if cur_track = @get('cur_track')
      soundManager.destroySound cur_track.smid()

    track = @playlist.tracks.getById audio_id

    App.vk.getTrackData track.get('audio_id'), (data) ->
      if info = data.error
        console.log info.error_code, info.error_msg
        alert "Ошибка Вконтакте API. Сейчас приложение перезапустится и всё будет ok."
        location.reload()
        return false
      track.set url: (data.response[0].url || @fail_url) if data.response
      @set cur_track: track
      App.player.trigger 'show_track_name'
      @createSound track, 'play'
    ,this

  playOnce: (track) ->
    @set once: track
    #App.player.trigger 'show_track_name'
    @createSound track, 'play'

  togglePause: () ->
    if track = @get 'once'
      soundManager.togglePause track.smid()
      return

    soundManager.togglePause @get('cur_track')?.smid()
    App.player.trigger 'toggle_pause'

  prev: ->
    if not @get('cur_track')
      @play()
      return

    cur_track =  @get('cur_track')
    soundManager.destroySound cur_track.smid()
    prev = @playlist.tracks.getPrev cur_track.get('audio_id')

    App.vk.getTrackData prev.get('audio_id'), (data) ->
      if data.response
        prev.set url: data.response[0].url || @fail_url
      @set cur_track: prev
      App.player.trigger 'show_track_name'
      @createSound prev, 'play'
    ,this

  next: ->
    if not @get('cur_track')
      @play()
      return

    cur_track = @get('cur_track')
    soundManager.destroySound cur_track.smid()
    next = @playlist.tracks.getNext cur_track.get('audio_id')
    
    # если трек был загружен заранее
    if soundManager.getSoundById next.smid()
      soundManager.play next.smid()
      @set cur_track: @next if @next
      delete @next
      return

    App.vk.getTrackData next.get('audio_id'), (data) ->
      if data.response
        next.set url: data.response[0].url || @fail_url
      @set cur_track: next
      App.player.trigger 'show_track_name'
      @createSound next, 'play'
    ,this

  loadNextTrack: ->
    console.info 'Загружаем следущий трек..'
    next = @playlist.tracks.getNext @get('cur_track').get('audio_id')

    App.vk.getTrackData next.get('audio_id'), (data) ->
      if data.response
        next.set url: data.response[0].url || @fail_url
      @set next: next
      @createSound next, 'load'
    ,this
  
  createSound: (track, param) ->
    switch param
      when 'play'
        autoPlay = true
      when 'load'
        autoPlay = false
      else
        autoPlay = true

    soundManager.createSound
      id: track.smid()
      url: track.get 'url'
      autoPlay: autoPlay
      autoLoad: true

  setPosition: (pos) ->
    soundManager.setPosition @get('cur_track')?.smid(), pos

  saveVolume: (val) ->
    volume = if val >= 0 and val <= 100 then val else 100
    $.cookie('volume', volume, { expires: 60*60*24*366 });

  saveDurMode: (val) ->
    dur_mod = if val == 'pos' || val == 'neg' then val else 'pos'
    $.cookie('duration_mode', dur_mod, { expires: 60*60*24*366 });

  memory: ->
    (soundManager.getMemoryUse()/1024/1024).toFixed(2) + " mb"