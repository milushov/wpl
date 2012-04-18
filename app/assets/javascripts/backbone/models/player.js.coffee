class Playlists.Models.Player extends Backbone.Model
  defaults:
    state: 'pause'
    prevTrack: null
    currentTrack: null
    nextTrack: null
    duration_mode: 'pos' # 'neg'

  initialize: ->
    console.log 'Player model created'



  reset: ->
    soundManager.reboot()

  # грузит плейлист, берет из него 3 трека, получает для каждого url,
  # сохраняет в модели и инициирует проигрывание текущего трека
  loadAndPlay: (playlist, audio_id)->
    if playlist
      if @playlist != playlist.get('_id')
        @playlist = playlist

    @current_tracks = @playlist.tracks.getThreeTracksForPlaying(audio_id)

    # выбираем id'шники трех текущих треков
    ids = [
      @current_tracks.prev.get('audio_id')
      @current_tracks.current.get('audio_id')
      @current_tracks.prev.get('audio_id')
    ]

    # получаем ссылку для воспроизведения для каждого из трех треков
    App.vk.getThreeTrackData ids, (data)->
      data = data.response
      
      cur_tracks = App.player.model.current_tracks
      
      if data.prev then cur_tracks.prev.set(url: data.prev.url) else @urlSrcError()
      if data.current then cur_tracks.current.set(url: data.current.url) else @urlSrcError()
      if data.next then cur_tracks.next.set(url: data.next.url) else @urlSrcError()

      # сохраняем текщие треки
      App.player.model.set(
        prevTrack: cur_tracks.prev
        currentTrack: cur_tracks.current
        nextTrack: cur_tracks.next
      )

      soundManager.createSound(
        id: cur_tracks.prev.get('audio_id')
        url: cur_tracks.prev.get('url')
      )

      soundManager.createSound(
        id: cur_tracks.current.get('audio_id')
        url: cur_tracks.current.get('url')
      )

      soundManager.createSound(
        id: cur_tracks.next.get('audio_id')
        url: cur_tracks.next.get('url')
      )

      # обращаемся к вьюхе, чтобы не нарушать концепцию MVC
      App.player.play()

  play: (audio_id)->
    if audio_id
      if audio_id == @get('currentTrack').get('audio_id')
        soundManager.play @get('currentTrack').get('audio_id')
      else
        @loadAndPlay(null, audio_id)
    else
      soundManager.play @get('currentTrack').get('audio_id')

  togglePause: ()->
    soundManager.togglePause @get('currentTrack').get('audio_id')

  prev: ->
    l 'prev'
    id = @get('prevTrack').get('audio_id')
    soundManager.play(id)

  next: ->
    l 'next'
    id = @get('nextTrack').get('audio_id')
    soundManager.play(id)
    
  memory: ->
    (soundManager.getMemoryUse()/1024/1024).toFixed(2) + " mb"

  urlSrcError: ()->
    alert 'o_O Вы нашли очень редкую ошибку. Экземпляр данного трека был удален из VK.'