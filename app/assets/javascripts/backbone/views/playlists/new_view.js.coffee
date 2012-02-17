Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.NewView extends Backbone.View
  template: JST["backbone/templates/playlists/new"]

  events:
    "submit #new-playlist": "save"

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
      success: (playlist) =>
        @model = playlist
        window.location.hash = "/#{@model.id}"

      error: (playlist, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
