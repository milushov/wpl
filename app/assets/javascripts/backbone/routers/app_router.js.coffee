class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'u/:user_id'        : 'getUserProfile'
    'tag/:tag'          : 'getPlaylistsByTag'
    ':url/comments'     : 'showComments'
    'new'               : 'newPlaylist'
    'last'              : 'getLastPlaylists'
    'popular'           : 'getPopularPlaylist'
    ':url'              : 'getPlaylist'
    '.*'                : 'myProfile'
    '*path'             : 'notFound'
  initialize: (options)->
    console.log 'Routers.AppRouter initialize()'
    @vk = new Playlists.Models.Vk()
    if not @vk.isAuth() then console.error 'Вы не залогинены! Атата! Как не стыдно!'

    # подписываем роутер на события
    @.on 'playlist_loaded', (playlist)-> @showPlaylist(playlist)
    @.on 'user_data_loaded', (user_data)-> @showUserProfile(user_data)
    @.on 'playlists_by_tag_data_loaded', (playlists_data)-> @showPlaylistsByTag(playlists_data)
    
    @.on 'user_follow', (data)->
      window.user_profile = {} # очищаем, чтобы загрузить обновленные данные
      @follow_switch = 'user_follow' # чтобы в @showUserProfile() добавить новозафоловленнго юзера в my_profile.followees
      @getUserProfile data.id
    
    @.on 'user_unfollow', (data)->
      window.user_profile = {}
      @follow_switch = 'user_unfollow'
      @getUserProfile data.id

    @.on 'playlist_follow', (data)->
      @follow_switch = 'playlist_follow'
      @getPlaylist data.id
    
    @.on 'playlist_unfollow', (data)->
      @follow_switch = 'playlist_unfollow'
      @getPlaylist data.id

    @follow_switch = false

    # в начале тут только мои плейлисты
    @playlists = new Playlists.Collections.PlaylistsCollection(options.playlists)

  # request for user profile (!) data
  getUserProfile: (user_id) ->
    console.log 'Routers.AppRouter getUserProfile()', user_id

    mid = if not $.isEmptyObject(my_profile) then my_profile['user']['screen_name'] else ''
    uid = if not $.isEmptyObject(user_profile) then user_profile['user']['screen_name'] else ''

    if user_id == mid
      @myProfile()
    else if user_id == uid
      @showUserProfile(user_profile)
    else
      @vk.getProfile(user_id)
      
  showUserProfile: (user_data) ->
    console.log 'Routers.AppRouter showUserProfile()', user_data
    window.user_profile = user_data
    
    # добавляем или удаляем пользователя из нашего списка подписчиков
    if @follow_switch == 'user_follow'
      my_profile.followees.push user_data.user
      @follow_switch = false
    else if @follow_switch == 'user_unfollow'
      for f in my_profile.followees
        if f.id == user_data.user.id
          i = my_profile.followees.indexOf f
          my_profile.followees.splice i, 1
          break
      @follow_switch = false

    # to available always a collection playlists of current user
    # and it was possiply to make like this: @playlists.getByUrl(url)
    playlists_both_people = _.clone(user_profile.playlists)
    
    my_profile.playlists.forEach (pl)-> playlists_both_people.push(pl)

    @playlists = new Playlists.Collections.PlaylistsCollection( playlists_both_people )

    $("#app").html( new Playlists.Views.User.ShowView(user_data).render().el )
        
    @ok()

  myProfile: ->
    console.log 'Routers.AppRouter myProfile()', my_profile
    $("#app").html( new Playlists.Views.User.ShowMeView(my_profile).render().el ) if user_profile
    @ok()

  # request for playlist (!) model
  getPlaylist: (url) ->
    console.log 'Routers.AppRouter getPlaylist()', url
    if playlist = @playlists.getByUrl(url)
      @showPlaylist(playlist)
    else
      @vk.getPlaylist(url)

  showPlaylist: (playlist) ->
    console.log 'Routers.AppRouter showPlaylist()', playlist

    # добавляем или удаляем плейлист из нашего списка
    # и добавляем/удаляем себя из списка фолловеров листа
    if @follow_switch == 'playlist_follow'
      playlist.get('followers').push(my_profile.user)
      my_profile.playlists.push playlist.toJSON()
      @follow_switch = false
    else if @follow_switch == 'playlist_unfollow'
      my_id = my_profile.user.id
      playlist_followers = playlist.get('followers')
      for f in playlist_followers
        if f.id == my_id
          i = playlist_followers.indexOf f
          playlist_followers.splice i, 1
          break

      url = playlist.get('url')
      for p in my_profile.playlists
        if p.url == url
          i = my_profile.playlists.indexOf p
          my_profile.playlists.splice i, 1
          break

      @follow_switch = false

    @playlists.add playlist

    if @show_comments
      @show_comments = false
      @showComments playlist.get 'url'
      return

    $("#app").html( new Playlists.Views.Playlists.ShowView(
      model: playlist
    ).render().el )

    @ok()

  showComments: (url) ->
    unless playlist = @playlists.getByUrl url
      @getPlaylist url
      @show_comments = true
      return console.log 'playlist in App.playlist dont exist'

    # BUG: way, when i use fetch method for obtain comments - not work!
    if playlist.comments.length == 0
      playlist.fetch
      @vk.getComments playlist.get('url'), 0, 10, (data)->
        if not data.error       
          playlist.comments.add data
          playlist.comments.url = "#{playlist.url()}/comments"

          $("#app").html( new Playlists.Views.Comments.IndexView(
            playlist
          ).render().el )
          @ok()
        else
          notify data
          @ok()
      ,this  
    else
      $("#app").html( new Playlists.Views.Comments.IndexView(
        playlist
      ).render().el )
      @ok()

  # request for playlists data
  getPlaylistsByTag: (tag) ->
    console.log 'Routers.AppRouter getPlaylistsByTag()', tag
    @vk.getPlaylistsByTag(tag)

  showPlaylistsByTag: (playlists_data) ->
    $("#app").html( new Playlists.Views.Playlists.PlaylistsByTagView(
      playlists: playlists_data.playlists,
      tag: playlists_data.tag
    ).render().el )

    # добавляем модели новых плейлистов
    @playlists = new Playlists.Collections.PlaylistsCollection( my_profile['playlists'] )
    @playlists.add playlists_data.playlists

    @ok()

  getLastPlaylists: ()->
    

  getPopularPlaylist: ()->


  newPlaylist: ->
    @new_playlist_view = new Playlists.Views.Playlists.NewView(me: my_profile.user)
    $("#app").html(@new_playlist_view.render().el)

    $.get '/api/playlists/tags', (data)->
      $('#edit_tags').tagit
        availableTags: data
        allowSpaces: true
        placeholderText: 'Теги плейлиста'
    , 'json'

    @ok()

  notFound: ->
    $("#app").html "<center><h1 style='font-size: 600px; margin-top: 250px;'>404</h1></center>"

  ok: ()->
    $('.tooltip').remove()
    $('#app').tooltip
      selector: "a[rel=tooltip]"
      delay:
        show: 420, hide: 100
    bind_urls()
    loading('off')