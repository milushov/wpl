P.Views.Playlists ||= {}

class P.Views.Playlists.PlaylistView extends Backbone.View
  template: JST["backbone/templates/playlists/playlist"]

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
