Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.PlaylistsByTagView extends Backbone.View
  template: JST["backbone/templates/playlists/playlists_by_tag"]

  initialize: (options) ->
    console.log 'Views.Playlists.PlaylistsByTagView initialize(options)', options

  render: ->
    console.log 'Views.Playlists.PlaylistsByTagView render()'

    $(@el).html( @template(
      tag: @options.tag
    ) )

    $(@el).find('#playlists').html( 
      new Playlists.Views.Playlists.IndexView(
        collection: new Playlists.Collections.PlaylistsCollection(
          @options.playlists
        )
      ).render().el
    )

    return this 