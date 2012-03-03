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
		
		# создаем коллекцию
		@playlists = new Playlists.Collections.PlaylistsCollection(options.playlists)
		#@playlists.reset options.playlistsa


	routes:
		'.*'        : 'index'
		'/playlist/:id': 'playlist'
		'/index'    : 'index'
		'/new'      : 'newPlaylist'
		'/:id/edit' : 'edit'
		'/:id'      : 'show'

	index: ->
		console.log('index route')
		# передаем главной вьюхе ВСЮ коллекцию плейлистов
		@view = new Playlists.Views.Playlists.IndexView( collection: @playlists )
		$("#app").html( @view.render().el )

	playlist: ->
		console.log 'Routers.PlaylistsRouter playlist()', @options

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
