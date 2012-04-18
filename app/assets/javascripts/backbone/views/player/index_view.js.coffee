Playlists.Views.Player ||= {}
class Playlists.Views.Player.IndexView extends Backbone.View
  events:
    'click #prev_btn': 'prev'
    'click #play_btn': 'togglePause'
    'click #next_btn': 'next'
    'click #duration': 'changeDurationMode'

  el: '#player_ui'

  initialize: ->
    console.log 'Player.IndexView init', @model, @el
    @duration_mode = @model.get('duration_mode')

    @.on 'next', ()-> @next()

  loadAndPlay: (playlist, audio_id)->
    @model.loadAndPlay(playlist, audio_id)

  togglePause: ->
    @model.togglePause()

  play: (audio_id)->
    @model.play(audio_id)
    $("#track_info #name").text @model.get('currentTrack').getName()

  prev: ->
    @model.prev()

  next: ->
    @model.next()

  updatePlayProgress: (pos, dur)->
    pos = Math.round pos/1000
    dur = Math.round dur/1000
    $('#progress_line #play').width "#{ (pos/dur*100).toFixed(2) }%"
    pers = (pos/dur*100).toFixed(2)
    $('#progress_line #play').animate width: "#{pers}%", 330, 'easeOutCirc'
    @updateDuraion()

  changeDurationMode: ()->
    mode = if @model.get('duration_mode') == 'pos' then 'neg' else 'pos'
    @model.set duration_mode: mode
    @duration_mode = mode
    @updateDuraion()

  updateDuraion: (pos, dur)->
    if not pos or not dur
      pos = Math.round(soundManager.getSoundById(@model.get('currentTrack').get('audio_id')).position/1000)
      dur = Math.round(soundManager.getSoundById(@model.get('currentTrack').get('audio_id')).duration/1000)

    if @duration_mode == 'pos'
      min = (pos/60).toFixed(0)
      sec = if (pos%60).toString().length == 2 then "#{(pos%60)}" else "0#{(pos%60)}"
      dur_pos = "#{min}:#{sec}"
    else 
      min = ((dur-pos)/60).toFixed(0)
      sec = if ((dur-pos)%60).toString().length == 2 then "#{(dur-pos)%60}" else "0#{(dur-pos)%60}"
      neg_pos = "#{min}:#{sec}"

    $("#track_info #duration").text( dur_pos || neg_pos)
    console.log(pos)

  # Загружаем в плеер треки из текущего плейлиста,
  # а трек по которому мы щелкнули сразу воспроизводим.
  # Если данный плейлист уже в плеере,
  # то ищем трек во в модели плеера.
  load_playlist_and_play_track: (e)->
    console.log e