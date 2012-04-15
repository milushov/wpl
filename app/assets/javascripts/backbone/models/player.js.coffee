class Playlists.Models.Player extends Backbone.Model
  defaults:
    state: 'pause'
    prevTrack: null
    currentTrack: null
    nextTrack: null

  initialize: ->
    console.log 'Player model created'

  reset: ->
    soundManager.reboot()

  loadAndPlay: (playlist, track_id)->
    if @playlist != playlist.get '_id'
      @playlist = playlist

    @current_tracks = @playlist.tracks.getThreeTracksForPlaying track_id

    # выбираем id'шники трех текущмх треков
    ids = [
      @current_tracks.prev.get('audio_id')
      @current_tracks.current.get('audio_id')
      @current_tracks.prev.get('audio_id')
    ]

    # получаем ссылку для воспроизведения для каждого из трех треков
    App.vk.getThreeTrackData ids, (data)=>
      data = data.response
      cur_tracks = App.player.model.current_tracks
      if !data.prev then @urlSrcError() else
        cur_tracks.prev.set url: data.prev.url
      if !data.current then @urlSrcError() else
        cur_tracks.current.set url: data.current.url
      if !data.next then @urlSrcError() else
        cur_tracks.next.set url: data.next.url

      App.player.model.set prevTrack: cur_tracks.prev
      App.player.model.set currentTrack: cur_tracks.current
      App.player.model.set nextTrack: cur_tracks.next

      App.player.model.get('currentTrack').set sound: soundManager.createSound
        id: cur_tracks.prev.get '_id'
        url: cur_tracks.prev.get 'url'
        onpause: ()->
          App.player.model.trigger("changed")
        onresume: ()->
          App.player.model.trigger("changed")
        onfinish: ()->
          App.player.model.trigger("changed")

      App.player.model.play()

  play: ()->
    currentTrack = @get('currentTrack')
    currentTrack.get('sound').play( @get('currentTrack').get('_id') )

  render: ->
    console.log 'render'

  prev: ->
    console.log 'prev'

  togglePause: ->
    if @get('currentTrack').get('sound').togglePause() then @trigger("changed")

  next: ->
    currentTrack = @get('nextTrack')
    currentTrack.get('sound').play( @get('nextTrack').get('_id') )



  urlSrcError: ()->
    alert 'o_O Вы нашли очень редкую ошибку. Экземпляр данного трека был удален из VK.'