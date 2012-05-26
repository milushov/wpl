Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.IndexView extends Backbone.View
  template: JST["backbone/templates/comments/index"]

  initialize: () ->
    #@options.comments.bind('reset', @addAll)

  addAll: () =>
    @options.comments.each(@addOne)

  addOne: (comment) =>
    view = new Playlists.Views.Comments.CommentView({model : comment})
    @$("#comments").append(view.render().el)

  render: =>    
    url = @options.get 'url'
    i_follow = false
    if my_profile.playlists.length != 0
      i_follow = p for p in my_profile.playlists when p.url == url
    i_follow = if i_follow then true else false

    playlist_data = @options.toJSON()
    playlist_data.i_follow = i_follow
    
    $(@el).html(@template(playlist_data))

    @addAll()
    return this
