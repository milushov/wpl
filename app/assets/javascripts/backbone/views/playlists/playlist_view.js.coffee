Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.PlaylistView extends Backbone.View
  template: JST["backbone/templates/playlists/playlist"]

  tagName: 'div'
  className: 'playlist'

  events:
    "click .destroy" : "destroy"

  initialize: () ->
    console.log 'Playlists.PlaylistView', @el

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
