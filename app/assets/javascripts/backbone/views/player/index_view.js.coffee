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

    @.on 'show_track_name', -> @showTrackName()
    @.on 'toggle_pause', -> @togglePause('auto')

  togglePause: (how)->
    if how and how == 'auto'
      # меняем вид кнопки в влеере и "на треке"
    else
      @model.togglePause()

  play: (track)->
    @model.play(track)
  
  playOnce: (track)->
    @model.playOnce(track)

  showTrackName: ->
    $("#track_info #name").html @model.get('currentTrack').getName()

  prev: ->
    if @model.get 'once'
      return
    @model.prev()

  next: ->
    if @model.get 'once'
      return
    @model.next()

  updatePlayProgress: (pos, dur)->
    pos = Math.round pos/1000
    dur = Math.round dur/1000
    pers = (pos/dur*100).toFixed(2)
    $('#play').width "#{pers}%"
    #l pers
    # $('#progress_line #play').animate width: "#{pers}%", 330, 'easeOutCirc'
    @updateDuraion()

  updateLoadingProgress: (loaded, total)->
    loaded = Math.round loaded
    total = Math.round total
    pers = (loaded/total*100).toFixed(2)
    $('#load').width "#{pers}%"
    #l pers
    # $('#progress_line #play').animate width: "#{pers}%", 330, 'easeOutCirc'
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

    $("#track_info #duration").text(dur_pos || neg_pos)