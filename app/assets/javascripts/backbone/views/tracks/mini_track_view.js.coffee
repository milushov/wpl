Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.MiniTrackView extends Backbone.View
  template: JST["backbone/templates/tracks/mini"]

  events :
    'click .play_btn a' : 'play'

  tagName: 'div'
  className: 'track_mini'

  initialize: () ->
    @model = @options.model
    @options = null
    $(@el).attr 'id', 'track_id-'+@model.get '_id'

  play: ->
    console.log 'Views.Tracks.MiniTrackView play()'
    #@model.voteUp()

  render: ->
    #console.log 'Views.Tracks.MiniTrackView render()'
    $(@el).html( @template( @model.toJSON() ) )
    return this
