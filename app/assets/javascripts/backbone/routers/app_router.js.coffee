class Playlists.Routers.AppRouter extends Backbone.Router
	initialize: (options) ->
		@vk = new Playlists.Models.Vk
		
		if @vk.isAuth()
			console.log '@vk.isAuth()', @vk.isAuth()
			# странная фигня: не работает @navigate('index')
			@navigate 'index', true
		else
			return false
			alert 'вы не залогинены! атата! как не стыдно!'
		
		# по идее тут будет коллекция всех плейлистов пользовтеля
		@playlists = new Playlists.Collections.PlaylistsCollection options.playlists
		# @playlists.reset options.playlistsa

	routes:
		'playlist/:id': 'showPlaylist'
		'index'    : 'index'
		'.*'       : 'index'
		'new'      : 'newPlaylist'
		':id/edit' : 'edit'
		':id'      : 'showProfile' # сюда поставить регулярку

	index: ->
		console.log('index route')
		# передаем главной вьюхе ВСЮ коллекцию плейлистов
		@view = new Playlists.Views.Playlists.IndexView( collection: @playlists )
		$("#app").html( @view.render().el )

	showPlaylist: (id) ->
		console.log 'Routers.AppRouter showPlaylist()', id

		console.log playlist = @playlists.getByUrl(id)
		@view = new Playlists.Views.Playlists.ShowView(model: playlist)
		$("#app").html( @view.render().el )

	startPage: ->
		console.log('Routers.AppRouter startPage')
		@startPageView = new Playlists.Views.Profile.IndexView()
		$("#app").html( @startPageView.render().el )
		# веременный костыль
		$("#playlists").html(' ');

	newPlaylist: ->
		@view = new Playlists.Views.Playlists.NewView(collection: @playlists)
		$("#playlists").html(@view.render().el)

	showProfile: (id) ->
		console.log('Routers.AppRouter showProfile')
		playlist = @playlists.get(id)

		@view = new Playlists.Views.Playlists.ShowView(model: playlist)
		$("#playlists").html(@view.render().el)

	edit: (id) ->
		console.log('edit route')
		playlist = @playlists.get(id)

		@view = new Playlists.Views.Playlists.EditView(model: playlist)
		$("#playlists").html(@view.render().el)
