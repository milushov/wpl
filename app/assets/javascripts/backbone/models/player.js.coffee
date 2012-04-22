class Playlists.Models.Player extends Backbone.Model
  defaults:
    state: 'pause'
    currentTrack: null
    duration_mode: 'pos' # 'neg'

  initialize: ->
    console.log 'Player model created'
    @fail = 'http://vk.com/mp3/bb2.mp3'

  reset: ->
    soundManager.reboot()

  play: (track = null)->
    if track
      audio_id = track.get 'audio_id'
      playlist_id = track.get 'playlist_id'
    else
      @playlist = App.playlists.getByUrl curUrl()[1..]
      audio_id = @playlist.tracks.at(0).get 'audio_id'
      playlist_id = @playlist.get '_id'

    if @playlist
      if @playlist.get('_id') != playlist_id
        @playlist = App.playlists.getById playlist_id
    else
      @playlist = App.playlists.getById playlist_id

    # если пытаемя задействовать текущий трек
    if cur_track = @get('currentTrack')
      if cur_track.smid() == "#{playlist_id}:#{audio_id}"
        @togglePause()
        return

    if @get('currentTrack')
      soundManager.destroySound @get('currentTrack').smid()

    track = @playlist.tracks.getById audio_id

    App.vk.getTrackData track.get('audio_id'), (data)->
      if data.response
        track.set url: data.response[0].url || @fail
      @set currentTrack: track
      App.player.trigger 'show_track_name'
      soundManager.createSound
        id: track.smid()
        url: track.get 'url'
        autoPlay: true
    ,this

  playOnce: (track)->
    @set once: track
    #App.player.trigger 'show_track_name'
    soundManager.createSound
      id: track.smid()
      url: track.get 'url'
      autoPlay: true

  togglePause: ()->
    if @get 'once'
      soundManager.togglePause @get('once').smid()
      return

    soundManager.togglePause @get('currentTrack')?.smid()
    App.player.trigger 'toggle_pause'

  prev: ->
    if not @get('currentTrack')
      @play()
      return
    soundManager.destroySound @get('currentTrack').smid()

    prev = @playlist.tracks.getPrev @get('currentTrack').get('audio_id')

    App.vk.getTrackData prev.get('audio_id'), (data)->
      if data.response
        prev.set url: data.response[0].url || @fail
      @set currentTrack: prev
      App.player.trigger 'show_track_name'
      soundManager.createSound
        id: prev.smid()
        url: prev.get 'url'
        autoPlay: true
    ,this

  next: ->
    if not @get('currentTrack')
      @play()
      return
    soundManager.destroySound @get('currentTrack').smid()

    next = @playlist.tracks.getNext @get('currentTrack').get('audio_id')
    
    if soundManager.getSoundById next.smid()
      soundManager.play next.smid()
      if @next
        @set currentTrack: @next
      delete @next
      return

    App.vk.getTrackData next.get('audio_id'), (data)->
      if data.response
        next.set url: data.response[0].url || @fail
      @set currentTrack: next
      App.player.trigger 'show_track_name'
      soundManager.createSound
        id: next.smid()
        url: next.get 'url'
        autoPlay: true
    ,this

  loadNextTrack: ->
    console.log 'Загружаем следущий трек..'
    next = @playlist.tracks.getNext @get('currentTrack').get('audio_id')

    App.vk.getTrackData next.get('audio_id'), (data)->
      if data.response
        next.set url: data.response[0].url || @fail
      @set next: next
      soundManager.createSound
        id: next.smid()
        url: next.get 'url'
        autoLoad: true
    ,this
  
  memory: ->
    (soundManager.getMemoryUse()/1024/1024).toFixed(2) + " mb"

  urlSrcError: ()->
    alert 'o_O Вы нашли очень редкую ошибку. Экземпляр данного трека был удален из VK.'