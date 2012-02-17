Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.NewView extends Backbone.View
  template: JST["backbone/templates/tracks/new"]

  events:
    "submit #new-track": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (track) =>
        @model = track
        window.location.hash = "/#{@model.id}"

      error: (track, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
