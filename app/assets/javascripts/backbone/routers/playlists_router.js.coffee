class Playlists.Routers.PlaylistsRouter extends Backbone.Router
  initialize: (options) ->
    @playlists = new Playlists.Collections.PlaylistsCollection()
    @playlists.reset options.playlists

  routes:
    "/new"      : "newPlaylist"
    "/index"    : "index"
    "/:id/edit" : "edit"
    "/:id"      : "show"
    ".*"        : "index"

  newPlaylist: ->
    @view = new Playlists.Views.Playlists.NewView(collection: @playlists)
    $("#playlists").html(@view.render().el)

  index: ->
    console.log('index route')
    @view = new Playlists.Views.Playlists.IndexView(playlists: @playlists)
    $("#playlists").html(@view.render().el)

  show: (id) ->
    playlist = @playlists.get(id)

    @view = new Playlists.Views.Playlists.ShowView(model: playlist)
    $("#playlists").html(@view.render().el)

  edit: (id) ->
    playlist = @playlists.get(id)

    @view = new Playlists.Views.Playlists.EditView(model: playlist)
    $("#playlists").html(@view.render().el)
