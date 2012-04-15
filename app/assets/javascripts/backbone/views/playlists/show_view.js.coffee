Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.ShowView extends Backbone.View
  template: JST["backbone/templates/playlists/show"]

  events:
    "click #play_all" : "playAll"

  tagName: 'div'
  id: 'playlist'

  initialize: () ->
    console.log 'Views.Playlists.ShowView initialize()', @options
    @model = @options.model
    @options = null
    $(@el).attr('id', 'playlistId_'+@model.get '_id')

  destroy: () ->
    @model.destroy()
    this.remove()
    return false

  playAll: ()->
    console.log 'Views.Playlists.ShowView playAll()'
    # передаем плейлист
    App.player.loadAndPlay @model

  render: ->
    console.log 'Views.Playlists.ShowView render()', @model

    $(@el).html( @template(
      name: @model.get 'name'
      description: @model.get 'description'
      tags: @model.get 'tags'
      image: @model.get 'image'
      followers: @model.get 'followers'
    ) )

    @model.tracks.each (track) =>
      $(@el).find('.tracks').append( new Playlists.Views.Tracks.TrackView(model: track).render().el )
      
    return this
