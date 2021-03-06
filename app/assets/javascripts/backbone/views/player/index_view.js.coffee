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
    @volume = @model.get('volume')
    @update = true # trigger for when we drag slider

    @.on 'show_track_name', -> @showTrackName()
    @.on 'toggle_pause', -> @togglePause('auto')
    @.on 'highlight_cur_track', -> @highlightTrack()

  togglePause: (how) ->
    if how and how == 'auto'
      # меняем вид кнопки в влеере и "на треке"
    else
      @model.togglePause()

  play: (track = null) ->
    @model.play(track)
    @showProgressLine()
  
  playOnce: (track = null) ->
    @model.playOnce(track)
    @showProgressLine()

  prev: ->
    return if @model.get 'once'
    @model.prev()

  next: ->
    return if @model.get 'once'
    @model.next()

  updatePlayProgress: (pos, dur) ->
    @updateDuraion()
    return unless @update
    pos = Math.round pos/1000
    dur = Math.round dur/1000
    pers = (pos/dur*100).toFixed(2)
    $('#play').width "#{pers}%"

    all = $('#progress_line').width()
    slider = "#{all/100*pers}px"
    $('#slider').css('left', slider)

    #l pers
    # $('#progress_line #play').animate width: "#{pers}%", 330, 'easeOutCirc'
    

  updateLoadingProgress: (loaded, total) ->
    loaded = Math.round loaded
    total = Math.round total
    pers = (loaded/total*100).toFixed(2)
    $('#load').width "#{pers}%"

  changeDurationMode: () ->
    mode = if @model.get('duration_mode') is 'pos' then 'neg' else 'pos'
    @model.set duration_mode: @duration_mode = mode
    @model.saveDurMode(mode)
    @updateDuraion()

  showTrackName: ->
    $("#track_info #name").html @model.get('cur_track').getName()

  updateDuraion: (pos, dur) ->
    # thiw will be piecon update
    #Piecon.setProgress(12)
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
      dur_neg = "-#{min}:#{sec}"

    $("#track_info #duration").text(dur_pos or dur_neg)

  setPosition: (percent) ->
    return false unless percent
    dur = soundManager.getSoundById(
      @model.get('cur_track').smid()
    ).duration

    # @model.get('cur_track').get('duration')

    pos = dur/100*percent
    @model.setPosition(pos)

  showProgressLine: () ->
    $('#progress_line').show()

  hideProgressLine: () ->
    $('#progress_line').hide()

  highlightTrack: ->  
    id = App.player.model.get('cur_track').get('_id')
    track_block = $("#track_id-#{ id }")
    $('.playing_track').removeClass 'playing_track'
    track_block.addClass 'playing_track'

    # dst = $(document).scrollTop()
    wh = $(window).height()
    bt = track_block.offset().top
    bh = track_block.height()
    
    y = Math.max 0, bt + bh - wh/2

    $(document).scrollTo top: y, left: 0,
      duration: 500,
      easing:'easeOutExpo'


