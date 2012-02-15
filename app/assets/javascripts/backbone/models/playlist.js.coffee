

class Playlists.Models.Track extends Backbone.Model
	
	defaults:
		track_id: null # id'шник трека у нас в базе
		artist: null
		title: null
		audio_id: null # состоит из owner_id + '_' + aid
		duration: 1

	initialize: ->
		console.log 'Track model start'

	

class Playlists.Models.Playlist extends Playlists.Models.Track
  paramRoot: 'playlist'

  defaults:
    name: null
    description: null
    tags: null
  
  initialize: ->
  	console.log 'Playlist model start'


class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/playlists'


