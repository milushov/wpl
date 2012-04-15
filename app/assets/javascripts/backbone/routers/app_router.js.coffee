class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'u/:user_id'        : 'getUserProfile'
    'new'               : 'newPlaylist'
    ':url'              : 'getPlaylist' 
    '.*'                : 'myProfile'
  
  initialize: (options)->
    # подписываем роутер на событие
    @.on 'playlist_loaded', (playlist) => @showPlaylist(playlist)
    @.on 'user_data_loaded', (user_data) => @showUserProfile(user_data)

    @vk = new Playlists.Models.Vk

    # по идее тут будет коллекция всех плейлистов пользовтеля
    @playlists = new Playlists.Collections.PlaylistsCollection(options.playlists)

  # request for playlist model
  getPlaylist: (url) ->
    console.log 'Routers.AppRouter getPlaylist()', url
    if playlist = @playlists.getByUrl(url)
      @showPlaylist(playlist)
    else
      @vk.getPlaylist(url)

  showPlaylist: (playlist) ->
    console.log 'Routers.AppRouter showPlaylist()', playlist
    playlist_view = new Playlists.Views.Playlists.ShowView(
      model: new Playlists.Models.Playlist (
        model: playlist
      )
    )
    $("#app").html( playlist_view.render().el )
    bind_urls()
    loading('off')


  getUserProfile: (user_id) ->
    console.log 'Routers.AppRouter getUserProfile()', user_id
    @vk.getProfile user_id

  showUserProfile: (user_data) ->
    console.log 'Routers.AppRouter showUserProfile()', user_data
    user_view = new Playlists.Views.User.ShowView(
        user_data
    )
    $("#app").html(user_view.render().el)
    bind_urls()
    loading('off')


  myProfile: ->
    console.log 'Routers.AppRouter myProfile()', user_profile

    if user_profile
      @startPageView = new Playlists.Views.User.ShowMeView(user_profile)
      $("#app").html( @startPageView.render().el )
    bind_urls()
    loading('off')

  newPlaylist: ->
    @view = new Playlists.Views.Playlists.NewView(collection: @playlists)
    $("#playlists").html(@view.render().el)
    loading('off')

  isAuth: ()->
    if @vk.isAuth() then true else
      console.error 'Вы не залогинены! Атата! Как не стыдно!'
      false