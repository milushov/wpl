Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
  template: JST['backbone/templates/tracks/track']

  events :
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

  play: ->
    console.log 'Views.Tracks.TrackView play()', @model
    App.player.play @model

  like: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'
    App.vk.vote 'like', pid, tid, (data)->
      console.log data
    ,this

  hate: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'
    App.vk.vote 'hate', pid, tid, (data)->
      console.log data
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
