Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.IndexView extends Backbone.View
  template: JST["backbone/templates/tracks/index"]

  initialize: () ->
    @options.tracks.bind('reset', @addAll)

  addAll: () =>
    @options.tracks.each(@addOne)

  addOne: (track) =>
    view = new Playlists.Views.Tracks.TrackView({model : track})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(tracks: @options.tracks.toJSON() ))
    @addAll()

    return this
