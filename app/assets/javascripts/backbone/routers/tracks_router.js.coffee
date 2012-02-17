class Playlists.Routers.TracksRouter extends Backbone.Router
  initialize: (options) ->
    @tracks = new Playlists.Collections.TracksCollection()
    @tracks.reset options.tracks

  routes:
    "/new"      : "newTrack"
    "/index"    : "index"
    "/:id/edit" : "edit"
    "/:id"      : "show"
    ".*"        : "index"

  newTrack: ->
    @view = new Playlists.Views.Tracks.NewView(collection: @tracks)
    $("#tracks").html(@view.render().el)

  index: ->
    @view = new Playlists.Views.Tracks.IndexView(tracks: @tracks)
    $("#tracks").html(@view.render().el)

  show: (id) ->
    track = @tracks.get(id)

    @view = new Playlists.Views.Tracks.ShowView(model: track)
    $("#tracks").html(@view.render().el)

  edit: (id) ->
    track = @tracks.get(id)

    @view = new Playlists.Views.Tracks.EditView(model: track)
    $("#tracks").html(@view.render().el)
