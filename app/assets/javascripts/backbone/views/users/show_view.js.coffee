Playlists.Views.User ||= {}

class Playlists.Views.User.ShowView extends Backbone.View
  template: JST['backbone/templates/users/show']

  events:
    'click #follow' : 'followUser'
    'click #unfollow' : 'unfollowUser'

  initialize: (options) ->
    console.log 'User.ShowView nitialize()'

  settings: () ->
    console.log 'User.ShowView settings'

  followUser: ->
    App.vk.follow 'user', @options.user.id

  unfollowUser: ->
    App.vk.follow 'user', @options.user.id, 'undo'

  render: =>
    console.log 'User.ShowView render', @el
    cur_uid = @options.user.id
    i_follow = false
    if my_profile.followees.length != 0
      i_follow = followee for followee in my_profile.followees when followee.id == cur_uid

    $(@el).html( @template(
      user: @options.user
      followers: @options.followers
      followees: @options.followees
      i_follow: i_follow
    ) )

    $(@el).find('#playlists').html( 
      new Playlists.Views.Playlists.IndexView(
        collection: new Playlists.Collections.PlaylistsCollection(
          @options.playlists
        )
      ).render().el
    )

    return this