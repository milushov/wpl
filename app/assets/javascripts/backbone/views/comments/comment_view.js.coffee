Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    'mouseover' : 'showReplyButton'
    'mouseout' : 'hideReplyButton'
    'click .destroy' : 'destroy'

  showReplyButton: ->
    $(@el).find('.reply_btn').show()

  hideReplyButton: ->
    $(@el).find('.reply_btn').hide()

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
