Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
  template: JST['backbone/templates/tracks/track']

  events :
    'mouseover' : 'showVoteButtons'
    'mouseout' : 'hideVoteButtons'
    'click .play_btn' : 'play'
    'click .up a'     : 'like'
    'click .down a'   : 'hate'
    'click .destroy'  : 'destroy'

  tagName: 'div'
  className: 'track'

  initialize: () ->
    @model = @options.model
    @options = null
    $(@el).attr 'id', "track_id-#{ @model.get("_id") }"

  showVoteButtons: ->
    $(@el).find('.lovers').hide()
    $(@el).find('.actions').show()

  hideVoteButtons: ->
    $(@el).find('.lovers').show()
    $(@el).find('.actions').hide()

  play: ->
    console.log 'Views.Tracks.TrackView play()', @model
    App.player.play @model

  like: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'
    App.vk.vote 'like', pid, tid, (data) ->
      if data.error
        return notify 'Вы уже голосовали за этот трек!'
      track = App.playlists.getById(pid).tracks.where(_id: tid)[0]
      track.get('lovers').pop()
      track.get('lovers').splice 0, 0, my_profile.user
      track.set real_lovers_count: track.get('real_lovers_count') + 1

      notify "Вы проголосовали за <b>#{ @model.get('title') }</b>", 'success'

      # красивая аниация
      console.log $(@el).html( @template( @model.toJSON() ) )
    ,this

  hate: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'
    App.vk.vote 'hate', pid, tid, (data)->
      track = App.playlists.getById(pid).tracks.where(_id: tid)[0]
      track.get('haters').push my_profile.user
      track.set real_haters_count: track.get('real_haters_count') + 1
      $(@el).slideUp 700, 'easeOutExpo',
        -> ( $(this).remove())
      @destroy
      notify "Данный трек <b>#{ @model.get('title') }</b> больше не будет вам попадаться", 'success'
      # @destroy if not App.settings.show_hidden_tracks

    ,this

  destroy: ->
    @model.destroy()
    this.remove()
    return false

  render: ->
    #console.log 'Views.Tracks.TrackView render()'
    $(@el).html( @template( @model.toJSON() ) )
    return this
