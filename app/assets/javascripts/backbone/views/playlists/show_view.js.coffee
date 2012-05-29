Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.ShowView extends Backbone.View
  template: JST['backbone/templates/playlists/show']

  events:
    'click #play_all' : 'playAll'
    'click #follow' : 'followPlaylist'
    'click #unfollow' : 'unfollowPlaylist'

  tagName: 'div'
  id: 'playlist'

  initialize: () ->
    console.log 'Views.Playlists.ShowView initialize()', @options
    @model = @options.model
    @options = null
    $(@el).attr('id', 'playlist_id:'+@model.get '_id')

  followPlaylist: ->
    App.vk.follow 'playlist', @model.get 'url'

  unfollowPlaylist: ->
    App.vk.follow 'playlist', @model.get('url'), 'undo'

  destroy: () ->
    @model.destroy()
    this.remove()
    return false

  # run the current playlist from the first track
  playAll: ()->
    App.player.play()

  render: ->
    console.log 'Views.Playlists.ShowView render()', @model
    url = @model.get 'url'
    i_follow = false
    if my_profile.playlists.length != 0
      i_follow = p for p in my_profile.playlists when p.url == url

    playlist_data = @model.toJSON()
    playlist_data.comments_url = "/#{@model.get 'url'}/comments"
    playlist_data.i_follow = i_follow
    $(@el).html @template(playlist_data)

    # adding playlist's id in track model for player needs
    playlist_id = @model.get('_id')

    for i,track of @model.tracks.models
      track.set(playlist_id: playlist_id)
      $(@el).find('.tracks').append( new Playlists.Views.Tracks.TrackView(model: track).render().el )
    
    this