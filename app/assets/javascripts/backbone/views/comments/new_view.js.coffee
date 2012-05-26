Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.NewView extends Backbone.View
  template: JST["backbone/templates/comments/new"]

  events:
    "submit #new-comment": "save"

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
      success: (comment) =>
        @model = comment
        window.location.hash = "/#{@model.id}"

      error: (comment, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
