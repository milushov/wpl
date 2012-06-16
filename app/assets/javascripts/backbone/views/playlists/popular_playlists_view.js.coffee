Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.PopularPlaylistsView extends Backbone.View
  template: JST['backbone/templates/playlists/popular_playlists']

  initialize: (options) ->

  render: ->
    $(@el).html @template()

    $(@el).find('#playlists').html( 
      new Playlists.Views.Playlists.IndexView(
        collection: new Playlists.Collections.PlaylistsCollection(
          @options.playlists
        )
      ).render().el
    )

    this 