class Playlists.Routers.AppRouter extends Backbone.Router
  routes:
    'playlist/:id'  :'showPlaylist'
    'access_token'  : 'saveToken'
    'login'         : 'login'
    'login/:to'     : 'login'
    'me'            : 'myProfile'
    'show_my_playlists': 'index'
    ':user_id'      : 'getUserProfile' # сюда поставить регулярку
    'new'           : 'newPlaylist'
    '.*'            : 'myProfile'
  
  initialize: (options)->
    # подписываем роутер на событие
    @.on 'user_data_loaded', (user_data) => @showUserProfile(user_data)

    @vk = new Playlists.Models.Vk
    # по идее тут будет коллекция всех плейлистов пользовтеля
    @playlists = new Playlists.Collections.PlaylistsCollection options.playlists
    @temp = {}    

  isAuth: ()->
    if @vk.isAuth() then true else
      console.log 'вы не залогинены! атата! как не стыдно!'

      current_url = $.url().attr('relative')
      current_url = current_url.slice(1, current_url.length)

      if current_url == '' then current_url = null
      if current_url
        @navigate "login/to=#{ current_url }", true
        $.cookie('to', current_url, { expires: 7 });
      else
        @navigate "login", true
      return false
    
    
    # @playlists.reset options.playlistsa


  index: ->
    if !@isAuth() then return false
    console.log('index route')
    # передаем главной вьюхе ВСЮ коллекцию плейлистов
    view = new Playlists.Views.Playlists.IndexView( collection: @playlists )
    $("#app").html( view.render().el )

  showPlaylist: (id) ->
    console.log 'Routers.AppRouter showPlaylist('+id+')'

    playlist = @playlists.getByUrl(id)
    if playlist
      @view = new Playlists.Views.Playlists.ShowView(model: playlist)
      $("#app").html( @view.render().el )
    else
      alert "Такого( #{id} ) плейлиста нет"
      return

  getUserProfile: (user_id) ->
    if !@isAuth() then return false
    console.log 'Routers.AppRouter getUserProfile()'

    @vk.getProfile user_id

  showUserProfile: (user_data) ->
    console.log 'Routers.AppRouter showUserProfile()'
    console.log user_data
    

    
    #user_view = Playlists.Views.Users.IndexView(  )
  
    #playlists_view = new Playlists.Views.Playlists.IndexView( collection: @temp.user.playlists )

    #@view = new Playlists.Views.Playlists.ShowView(model: playlist)
    #$("#playlists").html(@view.render().el)



  myProfile: ->
    if !@isAuth() then return false
    console.log('Routers.AppRouter myProfile()')

    if user_profile
      @startPageView = new Playlists.Views.Profile.IndexView(user_profile)
      $("#app").html( @startPageView.render().el )

    

    

    # веременный костыль
    $("#playlists").html(' ');

  newPlaylist: ->
    @view = new Playlists.Views.Playlists.NewView(collection: @playlists)
    $("#playlists").html(@view.render().el)

  login: (to)->
    console.log('Routers.AppRouter login()')
    $('body').html('<a class="btn btn-primary" onclick="App.vk.auth()" >Войти</a>')
    $('body').append(to)

  saveToken: ->
    @vk.saveNewAccessToken()
    to = $.cookie 'to'
    $.cookie 'to', null
    @navigate to, true
