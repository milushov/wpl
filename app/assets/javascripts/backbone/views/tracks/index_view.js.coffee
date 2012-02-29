Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.IndexView extends Backbone.View
  template: JST["backbone/templates/tracks/index"]

  tagName: 'div'
  className: 'track'

  events :
    "click .actions .up a" : "voteUp"
    "click .actions .down a" : "voteDown"

  initialize: () ->
    @options.tracks.bind('reset', @addAll)

  voteUp: ->
    console.log @, 'tracks/IndexView voteUp()'
    #@model.voteUp()

  voteDown: ->
    console.log @, 'tracks/IndexView voteDown()'

  addAll: () =>
    @options.tracks.each(@addOne)

  addOne: (track) =>
    view = new Playlists.Views.Tracks.TrackView({model : track})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(tracks: @options.tracks.toJSON() ))
    @addAll()

    return this
