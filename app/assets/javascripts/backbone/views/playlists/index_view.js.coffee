Playlists.Views.Playlists ||= {}

#  Главная вьюха которая отображает список плейлистов

class Playlists.Views.Playlists.IndexView extends Backbone.View

	template: JST["backbone/templates/playlists/index"]

	tagName: 'div'
	id: 'playlists'

	initialize: () ->
		console.log 'Playlists/IndexView initialize( @options )'
		@playlists = @options.collection
		@options = null
		@playlists.bind('reset', @addAll)

	addAll: () =>
		console.log 'Playlists/IndexView addAll()'
		@playlists.each(@addOne)

	addOne: (playlist) =>
		console.log 'Playlists/IndexView add One()'
		$(@el).append( new Playlists.Views.Playlists.PlaylistView(model: playlist).render().el)

	render: =>
		console.log 'Playlists/IndexView render()'
		$(@el).html @template()
		@playlists.each (playlist) =>
			$(@el).append( new Playlists.Views.Playlists.PlaylistView(model: playlist).render().el)
			return true

		#@addAll()
		return this
