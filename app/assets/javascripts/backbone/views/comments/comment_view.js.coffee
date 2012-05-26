Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    "click .destroy" : "destroy"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
