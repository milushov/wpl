class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'u/:user_id'        : 'getUserProfile'
    'new'               : 'newPlaylist'
    ':url'              : 'getPlaylist' 
    '.*'                : 'myProfile'
  
  initialize: (options)->
    console.log 'Routers.AppRouter initialize()'
    @vk = new Playlists.Models.Vk
    if not @vk.isAuth() then console.error 'Вы не залогинены! Атата! Как не стыдно!'

    # подписываем роутер на события
    @.on 'playlist_loaded', (playlist) => @showPlaylist(playlist)
    @.on 'user_data_loaded', (user_data) => @showUserProfile(user_data)

    @playlists = new Playlists.Collections.PlaylistsCollection(options.playlists)

  # request for user profile (!) data
  getUserProfile: (user_id) ->
    console.log 'Routers.AppRouter getUserProfile()', user_id

    if user_id == my_profile['user']['screen_name'] or user_id == my_profile['user']['uid']
      @myProfile()
    else if user_id == user_profile['user']['screen_name'] or user_id == user_profile['user']['uid']
      @showUserProfile(user_profile)
    else
      @vk.getProfile user_id
      

  showUserProfile: (user_data) ->
    console.log 'Routers.AppRouter showUserProfile()', user_data
    window.user_profile = user_data

    # to avaible always a collection playlists of current user
    # and it was possiply to make like this: @playlists.getByUrl(url)
    # тут какой-то ПИЗДЕЦ
    if user_profile['playlists']
      playlists_both = user_profile['playlists']
      playlists_both.push pl for pl in my_profile['playlists']
      @playlists = new Playlists.Collections.PlaylistsCollection(playlists_both)

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
    true