class Playlists.Models.Player extends Backbone.Model
  defaults:
    state: 'pause'
    prevTrack: null
    currentTrack: null
    loadNextTrack: null
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

    # если пытаемя заново запустить "играющий" трек
    if @get('currentTrack')
      # удаляем предыдущую тройку из SM2
      soundManager.destroySound @get('prevTrack').get('audio_id')
      soundManager.destroySound @get('currentTrack').get('audio_id')
      soundManager.destroySound @get('nextTrack').get('audio_id')
      if @get('currentTrack').get('audio_id') == audio_id
        @togglePause()
        return

    @current_tracks = @playlist.tracks.get3Tracks audio_id

    ids = [
      @current_tracks.prev.get 'audio_id'
      @current_tracks.current.get 'audio_id'
      @current_tracks.next.get 'audio_id'
    ]

    App.vk.getThreeTrackData ids, (data)->
      data = data.response
      cur_tracks = App.player.model.current_tracks
      
      if data.prev then cur_tracks.prev.set(url: data.prev.url || @fail) else @urlSrcError()
      if data.current then cur_tracks.current.set(url: data.current.url || @fail) else @urlSrcError()
      if data.next then cur_tracks.next.set(url: data.next.url || @fail) else @urlSrcError()

      # сохраняем текщие треки
      App.player.model.set
        prevTrack: cur_tracks.prev
        currentTrack: cur_tracks.current
        nextTrack: cur_tracks.next

      App.player.trigger 'show_track_name'

      soundManager.createSound
        id: cur_tracks.prev.get 'audio_id'
        url: cur_tracks.prev.get 'url'
      soundManager.createSound
        id: cur_tracks.current.get 'audio_id'
        url: cur_tracks.current.get 'url'
        autoPlay: true
      soundManager.createSound
        id: cur_tracks.next.get 'audio_id'
        url: cur_tracks.next.get 'url'

  togglePause: ()->
    soundManager.togglePause @get('currentTrack').get('audio_id')
    App.player.trigger 'toggle_pause'

  prev: ->
    soundManager.play @get('prevTrack').get('audio_id')
    soundManager.stop @get('currentTrack').get('audio_id')
    soundManager.destroySound @get('nextTrack').get('audio_id')

    # получаем слудующую тройку треков
    @current_tracks = @playlist.tracks.get3Tracks @get('prevTrack').get('audio_id')

    ids = [
      @current_tracks.prev.get 'audio_id'
      @current_tracks.current.get 'audio_id'
      @current_tracks.next.get 'audio_id'
    ]

    App.vk.getThreeTrackData ids, (data)->
      data = data.response
      cur_tracks = App.player.model.current_tracks
      
      if data.prev then cur_tracks.prev.set(url: data.prev.url || @fail) else @urlSrcError()
      if data.current then cur_tracks.current.set(url: data.current.url || @fail) else @urlSrcError()
      if data.next then cur_tracks.next.set(url: data.next.url || @fail) else @urlSrcError()

      # сохраняем текщие треки
      App.player.model.set
        prevTrack: cur_tracks.prev
        currentTrack: cur_tracks.current
        nextTrack: cur_tracks.next

      App.player.trigger 'show_track_name'

      soundManager.createSound
        id: cur_tracks.prev.get 'audio_id'
        url: cur_tracks.prev.get 'url'

  next: ->
    soundManager.destroySound @get('prevTrack').get('audio_id')
    soundManager.stop @get('currentTrack').get('audio_id')
    soundManager.play @get('nextTrack').get('audio_id')

    # получаем слудующую тройку треков
    @current_tracks = @playlist.tracks.get3Tracks @get('nextTrack').get('audio_id')

    ids = [
      @current_tracks.prev.get 'audio_id'
      @current_tracks.current.get 'audio_id'
      @current_tracks.next.get 'audio_id'
    ]

    App.vk.getThreeTrackData ids, (data)->
      data = data.response
      cur_tracks = App.player.model.current_tracks
      
      if data.prev then cur_tracks.prev.set(url: data.prev.url || @fail) else @urlSrcError()
      if data.current then cur_tracks.current.set(url: data.current.url || @fail) else @urlSrcError()
      if data.next then cur_tracks.next.set(url: data.next.url || @fail) else @urlSrcError()

      # сохраняем текщие треки
      App.player.model.set
        prevTrack: cur_tracks.prev
        currentTrack: cur_tracks.current
        nextTrack: cur_tracks.next

      App.player.trigger 'show_track_name'

      soundManager.createSound
        id: cur_tracks.next.get 'audio_id'
        url: cur_tracks.next.get 'url'

  loadNextTrack: ->
    console.log 'Загружаем следущий трек..'
    soundManager.load @get('nextTrack').get('audio_id')
    
  memory: ->
    (soundManager.getMemoryUse()/1024/1024).toFixed(2) + " mb"

  urlSrcError: ()->
    alert 'o_O Вы нашли очень редкую ошибку. Экземпляр данного трека был удален из VK.'