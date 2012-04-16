Playlists.Views.User ||= {}

class Playlists.Views.User.ShowMeView extends Backbone.View
  template: JST["backbone/templates/users/show_me"]

  initialize: () ->
    console.log 'Views.User.ShowMeView itialize()', @options

  settings: () ->
    console.log 'Views.User.ShowMeView settings'

  render: =>
    console.log 'Views.User.ShowMeView render(@el)', @el

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