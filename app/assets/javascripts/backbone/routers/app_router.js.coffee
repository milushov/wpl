class Playlists.Routers.AppRouter extends Backbone.Router
	initialize: (options) ->
		@vk = new Playlists.Models.Vk
		
		if @vk.isAuth()
			console.log '@vk.isAuth()', @vk.isAuth()
			# странная фигня: не работает @navigate('index')
			@navigate('index')
		else
			return false
			alert 'вы не залогинены! атата! как не стыдно!'
		
		# по идее тут будет коллекция всех плейлистов пользовтеля
		@playlists = new Playlists.Collections.PlaylistsCollection(options.playlists)
		#@playlists.reset options.playlistsa


	routes:
		'playlist/:id': 'playlist'
		'index'    : 'index'
		'new'      : 'newPlaylist'
		':id/edit' : 'edit'
		':id'      : 'show'
		'.*'        : 'index'

	index: ->
		console.log('index route')
		# передаем главной вьюхе ВСЮ коллекцию плейлистов
		@view = new Playlists.Views.Playlists.IndexView( collection: @playlists )
		$("#app").html( @view.render().el )

	playlist: (id) ->
		console.log 'Routers.PlaylistsRouter playlist()', id

		console.log playlist = @playlists.getByUrl(id)
		@view = new Playlists.Views.Playlists.ShowView(model: playlist)
		$("#app").html( @view.render().el )

	startPage: ->
		console.log('Routers.PlaylistsRouter startPage')
		@startPageView = new Playlists.Views.Profile.IndexView()
		$("#app").html( @startPageView.render().el )
		# веременный костыль
		$("#playlists").html(' ');

	newPlaylist: ->
		@view = new Playlists.Views.Playlists.NewView(collection: @playlists)
		$("#playlists").html(@view.render().el)

	show: (id) ->
		playlist = @playlists.get(id)

		@view = new Playlists.Views.Playlists.ShowView(model: playlist)
		$("#playlists").html(@view.render().el)

	edit: (id) ->
		console.log('edit route')
		playlist = @playlists.get(id)

		@view = new Playlists.Views.Playlists.EditView(model: playlist)
		$("#playlists").html(@view.render().el)
