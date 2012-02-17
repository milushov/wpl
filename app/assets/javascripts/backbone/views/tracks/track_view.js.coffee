Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
  template: JST["backbone/templates/tracks/track"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
