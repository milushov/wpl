Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.EditView extends Backbone.View
  template : JST["backbone/templates/playlists/edit"]

  events :
    "submit #edit-playlist" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (playlist) =>
        @model = playlist
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
