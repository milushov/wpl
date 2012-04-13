Playlists.Views.Profile ||= {}

class Playlists.Views.Profile.IndexView extends Backbone.View
  template: JST["backbone/templates/user/show_me"]

  initialize: (options) ->
    console.log 'Profile.IndexView nitialize()'

  settings: () ->
    console.log 'Profile.IndexView settings'

  render: =>
    console.log 'Profile.IndexView render', @el

    $(@el).html( @template(
      user: @options.user
      followers: @options.followers
      followees: @options.followees
    ) )

    $(@el).find('#playlists_wrap').html( 
      new Playlists.Views.Playlists.IndexView(
        collection: new Playlists.Collections.PlaylistsCollection(
          @options.playlists
        )
      ).render().el
    )

    l $(@el)

    return this