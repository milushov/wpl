Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.EditView extends Backbone.View
  template : JST["backbone/templates/tracks/edit"]

  events :
    "submit #edit-track" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (track) =>
        @model = track
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
