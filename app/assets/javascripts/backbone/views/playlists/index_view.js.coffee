Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.IndexView extends Backbone.View
	# главный шаблон который содержит все плейлисты
	template: JST["backbone/templates/playlists/index"]

	template_playlist: JST["backbone/templates/playlists/playlist"]

	el: $('#playlists')

	initialize: () ->
		console.log 'Playlists/IndexView nitialize( @options )', @options 

		@options.playlists.bind('reset', @addAll)

	addAll: () =>
		console.log 'Playlists/IndexView addAll()'
		@options.playlists.each(@addOne)

	addOne: (playlist) =>
		console.log 'Playlists/IndexView addOne()'
		view = new Playlists.Views.Playlists.PlaylistView({model : playlist})
		#@$("tbody").append(view.render().el)

	render: =>
		console.log 'Playlists/IndexView render()', @el

		@options.playlists.each (playlist)=>
			console.log @el
			playlistViewItem = new Playlists.Views.Playlists.PlaylistView playlist
			$( @el ).html( playlistViewItem.render().el )



		$( @el ).html( @template(playlists: @options.playlists.toJSON() ) )
		@addAll()

		return this
