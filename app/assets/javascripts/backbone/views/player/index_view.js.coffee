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

  togglePause: (how) ->
    if how and how == 'auto'
      # меняем вид кнопки в влеере и "на треке"
    else
      @model.togglePause()

  play: (track) ->
    @model.play(track)
  
  playOnce: (track) ->
    @model.playOnce(track)

  prev: ->
    return if @model.get 'once'
    @model.prev()

  next: ->
    return if @model.get 'once'
    @model.next()

  updatePlayProgress: (pos, dur) ->
    pos = Math.round pos/1000
    dur = Math.round dur/1000
    pers = (pos/dur*100).toFixed(2)
    $('#play').width "#{pers}%"
    #l pers
    # $('#progress_line #play').animate width: "#{pers}%", 330, 'easeOutCirc'
    @updateDuraion()

  updateLoadingProgress: (loaded, total) ->
    loaded = Math.round loaded
    total = Math.round total
    pers = (loaded/total*100).toFixed(2)
    $('#load').width "#{pers}%"
    @updateDuraion()

  changeDurationMode: () ->
    mode = if @model.get('duration_mode') is 'pos' then 'neg' else 'pos'
    @model.set duration_mode: @duration_mode = mode
    @updateDuraion()

  showTrackName: ->
    $("#track_info #name").html @model.get('cur_track').getName()

  updateDuraion: (pos, dur) ->
    if not pos or not dur
      pos = Math.round(
        soundManager.getSoundById(
          @model.get('cur_track').smid()
        ).position / 1000
      )

      dur = Math.round(
        soundManager.getSoundById(
          @model.get('cur_track').smid()
        ).duration / 1000
      )

    if @duration_mode is 'pos'
      min = (pos/60).toFixed(0)
      sec = "#{pos%60}"
      if sec.length is 1
        sec = '0' + sec
      dur_pos = "#{min}:#{sec}"
    else 
      min = ((dur-pos)/60).toFixed(0)
      sec = "#{(dur-pos)%60}"
      if sec.length is 1
        sec = '0' + sec
      dur_neg = "#{min}:#{sec}"

    $("#track_info #duration").text(dur_pos or dur_neg)