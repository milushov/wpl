Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.IndexView extends Backbone.View
  template: JST["backbone/templates/playlists/index"]

  el: $('playlists')

  initialize: () ->
    console.log 'Playlists/IndexView nitialize( @options )', @options 
    @options.playlists.bind('reset', @addAll)

  addAll: () =>
    console.log 'Playlists/IndexView addAll()'
    @options.playlists.each(@addOne)

  addOne: (playlist) =>
    console.log 'Playlists/IndexView add One()', @$
    view = new Playlists.Views.Playlists.PlaylistView({model : playlist})
    @$("tbody").append(view.render().el)

  render: =>
    console.log 'Playlists/IndexView render()', @el
    $( @el ).html( @template(playlists: @options.playlists.toJSON() ) )
    @addAll()

    return this
