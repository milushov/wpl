Playlists.Views.User ||= {}

class Playlists.Views.User.ShowView extends Backbone.View
  template: JST["backbone/templates/users/show"]

  initialize: (options) ->
    console.log 'User.ShowView nitialize()'

  settings: () ->
    console.log 'User.ShowView settings'

  render: =>
    console.log 'User.ShowView render', @el

    $(@el).html( @template(
      user: @options.user
      followers: @options.followers
      followees: @options.followees
    ) )

    $(@el).find('#playlists').html( 
      new Playlists.Views.Playlists.IndexView(
        collection: new Playlists.Collections.PlaylistsCollection(
          @options.playlists
        )
      ).render().el
    )

    return this