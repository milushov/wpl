Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.IndexView extends Backbone.View
  template: JST['backbone/templates/comments/index']
  reply_to: null

  events:
    'click #follow' : 'followPlaylist'
    'click #unfollow' : 'unfollowPlaylist'
    'click #add_new_comment' : 'newComment'
    'click .reply_btn' : 'reply'

  tagName: 'div'

  initialize: () ->
    # @options.comments.bind('reset', @addAll)

  reply: (e) ->
    @reply_to = $(e.srcElement).data('reply_to')
    # TODO: show username whom message we raply
    $.scrollTo top: 1, left: 0,
      duration: 500,
      easing:'easeOutExpo'
    @$('#new_comment textarea').focus()


  newComment: (reply_to = null) ->
    content = $('.content textarea').val()
    if content.length < 10
      return notify 'Длина сообщения должная быть больше 10 символов.'
    
    reply_to = @reply_to

    App.vk.saveNewComment @options.id, content, reply_to, (data) ->
      return notify data.error if data.error
      data.comment.user_data = my_profile.user
      comment = new Playlists.Models.Comment data.comment
      App.playlists.getById(@options.id).comments.add comment, at: 0
      @reply_to = null
      
      view = new Playlists.Views.Comments.CommentView model: comment
      @$("#new_comment").after(view.render().el)
      @$('#new_comment textarea').val('')
      # App.showComments @options.get 'url'
    ,this

  followPlaylist: ->
    App.vk.follow 'playlist', @options.get 'url'

  unfollowPlaylist: ->
    App.vk.follow 'playlist', @options.get('url'), 'undo'

  addAll: () =>
    @options.comments.each(@addOne)

  addOne: (comment) =>
    view = new Playlists.Views.Comments.CommentView model: comment
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
