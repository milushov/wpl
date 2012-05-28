Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    'mouseover' : 'showButtons'
    'mouseout' : 'hideButtons'
    'click .destroy' : 'destroy'

  showButtons: ->
    $(@el).find('.actions').show()
    $(@el).find('.reply_btn').show()

  hideButtons: ->
    $(@el).find('.actions').hide()
    $(@el).find('.reply_btn').hide()

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    content = $(@el).find('.content').html()
    $(@el).find('.content').html linkify(content)
    return this
