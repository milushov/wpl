Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.IndexView extends Backbone.View
  template: JST["backbone/templates/playlists/index"]

  initialize: () ->
    @options.playlists.bind('reset', @addAll)

  addAll: () =>
    @options.playlists.each(@addOne)

  addOne: (playlist) =>
    view = new Playlists.Views.Playlists.PlaylistView({model : playlist})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(playlists: @options.playlists.toJSON() ))
    @addAll()

    return this
