Playlists.Views.Comments ||= {}

class Playlists.Views.Comments.IndexView extends Backbone.View
  template: JST['backbone/templates/comments/index']
  reply_to: null
  update_cid: null

  events:
    'click #follow' : 'followPlaylist'
    'click #unfollow' : 'unfollowPlaylist'
    'click #add_new_comment' : 'new'
    'click .update_btn' : 'update'
    'click .delete_btn' : 'delete'
    'click .spam_btn' : 'spam'
    'click .reply_btn' : 'reply'

  tagName: 'div'

  initialize: () ->
    # @options.comments.bind('reset', @addAll)

  update: (e) ->
    @update_cid = $(e.srcElement).data 'cid'
    content = @$("#cid#{@update_cid} .content").text()
    @$('#new_comment textarea').val content.trim()
    @scroll()

  delete: (e) ->
    cid = $(e.srcElement).data 'cid'
    App.vk.deleteComment @options.id, cid, (data) ->
      return notify data.error if data.error
      pid = @options.id
      App.playlists.getById(pid).comments.where(_id: cid)[0].destroy()
      @$("#cid#{cid}").slideUp 700, 'easeOutExpo',
        -> ( $(this).remove())
      $('.tooltip').remove()
      notify 'Сообщение удалено', 'success'
    ,this

  spam: (e) ->
    cid = $(e.srcElement).data 'cid'
    App.vk.spamComment @options.id, cid, (data) ->
      return notify data.error if data.error
      pid = @options.id
      console.log App.playlists.getById(pid).comments.where(_id: cid)[0].destroy()
      @$("#cid#{cid}").slideUp 700, 'easeOutExpo',
        -> ( $(this).remove()) 
      $('.tooltip').remove()
      notify 'Сообщение помечено как спам', 'success'
    ,this

  reply: (e) ->
    @reply_to = $(e.srcElement).data 'reply_to'
    # TODO: show username whom message we reply
    @scroll()

  new: ->
    content = $('.content textarea').val()
    if content.length < 10
      return notify 'Длина сообщения должная быть больше 10 символов!'
    
    reply_to = @reply_to

    if @update_cid
      App.vk.updateComment @options.id, @update_cid, content, (data) ->
        return notify data.error if data.error
        data.comment.user_data = my_profile.user
        comment = new Playlists.Models.Comment data.comment
        # finding index of comment in comments collecion
        # for comment which we update
        playlist = App.playlists.getById @options.id
        comments = playlist.comments.where(_id: @update_cid)[0]
        i = playlist.comments.models.indexOf comments
        App.playlists.getById(@options.id).comments.add comment, at: i
        # make a view which replaces the updated comment
        view = new Playlists.Views.Comments.CommentView model: comment
        @$("#cid#{@update_cid}").replaceWith view.render().el
        @$('#new_comment textarea').val ''
        @update_cid = false
      ,this
    else
      @reply_to = null
      App.vk.saveNewComment @options.id, content, reply_to, (data) ->
        return notify data.error if data.error
        data.comment.user_data = my_profile.user
        comment = new Playlists.Models.Comment data.comment
        App.playlists.getById(@options.id).comments.add comment, at: 0
        
        view = new Playlists.Views.Comments.CommentView model: comment
        @$("#new_comment").after view.render().el
        @$('#new_comment textarea').val ''
      ,this

  scroll: ->
    $.scrollTo top: 1, left: 0,
      duration: 500,
      easing:'easeOutExpo'
    @$('#new_comment textarea').focus()

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
