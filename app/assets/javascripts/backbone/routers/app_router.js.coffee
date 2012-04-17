class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'u/:user_id'        : 'getUserProfile'
    'new'               : 'newPlaylist'
    ':url'              : 'getPlaylist' 
    '.*'                : 'myProfile'
  
  initialize: (options)->
    console.log 'Routers.AppRouter initialize()'
    @vk = new Playlists.Models.Vk()
    if not @vk.isAuth() then console.error 'Вы не залогинены! Атата! Как не стыдно!'

    # подписываем роутер на события
    @.on 'playlist_loaded', (playlist) -> @showPlaylist(playlist)
    @.on 'user_data_loaded', (user_data2) -> @showUserProfile(user_data2)

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
    $("#app").html( new Playlists.Views.Playlists.ShowView(
      model: playlist
    ).render().el )
    @ok()

  myProfile: ->
    console.log 'Routers.AppRouter myProfile()', my_profile
    $("#app").html( new Playlists.Views.User.ShowMeView(my_profile).render().el ) if user_profile
    @ok()

  newPlaylist: ->
    $("#app").html( new Playlists.Views.Playlists.NewView().render().el )

  ok: ()->
    bind_urls()
    loading('off')