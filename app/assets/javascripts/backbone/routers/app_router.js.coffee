class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'u/:user_id'        : 'getUserProfile'
    'tag/:tag'          : 'getPlaylistsByTag'
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

    # тут мои плейлиста
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
    
    # to available always a collection playlists of current user
    # and it was possiply to make like this: @playlists.getByUrl(url)
    playlists_both_people = _.clone(user_profile['playlists'])
    
    my_profile['playlists'].forEach (pl)-> playlists_both_people.push(pl)

    @playlists = new Playlists.Collections.PlaylistsCollection( playlists_both_people )

    $("#app").html( new Playlists.Views.User.ShowView(user_data).render().el )
        
    @ok()

  # request for playlist model
  getPlaylist: (url) ->
    console.log 'Routers.AppRouter getPlaylist()', url
    if playlist = @playlists.getByUrl(url)
      @showPlaylist(playlist)
    else
      @vk.getPlaylist(url)

  showPlaylist: (playlist) ->
    console.log 'Routers.AppRouter showPlaylist()', playlist
    @playlists.add playlist
    $("#app").html( new Playlists.Views.Playlists.ShowView(
      model: playlist
    ).render().el )
    @ok()

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


  myProfile: ->
    console.log 'Routers.AppRouter myProfile()', my_profile
    $("#app").html( new Playlists.Views.User.ShowMeView(my_profile).render().el ) if user_profile
    @ok()

  newPlaylist: ->
    $("#app").html( new Playlists.Views.Playlists.NewView(me: my_profile.user).render().el )

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