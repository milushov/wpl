Playlists.Views.Playlists ||= {}

# view of item of playlists collection, which located in user's home page
class Playlists.Views.Playlists.PlaylistView extends Backbone.View
  template: JST["backbone/templates/playlists/playlist"]

  events:
    'click .destroy' : 'destroy'
    'click .flip' : 'flip'

  tagName: 'div'
  className: 'playlist'

  initialize: (options) ->
    #console.log 'Views.Playlists.PlaylistView initialize(options)', options
    @model = options.model
    $(@el).attr 'id', 'playlist_id-'+@model.get '_id'

  destroy: () ->
    @model.destroy()
    this.remove()
    return false

  flip: () ->
    # TODO: there will be fancy feature turning cover image
    # of playlist to block with 3 first tracks
    if $(@el).find('.tracks').is(':hidden')
      $(@el).find('.info').hide()
      $(@el).find('.tracks').show()
    else
      $(@el).find('.tracks').hide()
      $(@el).find('.info').show();

  render: ->
    #console.log 'Views.Playlists.PlaylistView render(@model)', @model
    $(@el).html( @template(
      name: @model.get 'name'
      description: @model.get 'description'
      tags: @model.get 'tags'
      image: @model.get 'image'
      url: @model.get 'url'
      followers_count: @model.get 'followers_count'
    ) )

    count_per_list = 2

    @model.tracks.each (track) =>
      return if count_per_list == 0
      $(@el).find('.tracks').append(new Playlists.Views.Tracks.MiniTrackView(model: track).render().el)
      count_per_list -= 1
      
    return this 