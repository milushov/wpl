class Playlists.Models.Playlist extends Backbone.Model
	defaults:
		_id: null
		name: null
		image: null
		description: null
		tags: null
		url: null
		creator: null


	initialize: (options)->
		console.log( 'Playlist model created' )
		@tracks = @nestCollection('tracks', new Playlists.Collections.TracksCollection(options.tracks))



class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
	model: Playlists.Models.Playlist
	url: '/api/playlists'


	initialize: ()->
		console.log 'Playlist collection created'


	getByUrl: (url)->
		ret = {}
		@each (model)->
			if model.get('url') == url then ret = model
		return ret ? ret : false