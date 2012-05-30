Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.SearchPlaylistsView extends Backbone.View
  template: JST['backbone/templates/playlists/search']

  initialize: () ->
    # console.log 'Views.Playlists.PlaylistsByTagView initialize(options)', options
    

  render: ->
    $(@el).html( @template(
      query: @options.query
    ) )

    view = new Playlists.Views.Playlists.IndexView(
      collection: new Playlists.Collections.PlaylistsCollection(
        @options.playlists
      )
    )
    
    $(@el).find('#playlists').html view.render().el

    this 