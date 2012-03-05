class Playlists.Models.Track extends Backbone.Model
	#paramRoot: 'track'

	initialize: ->
		console.log 'Track model ctreated'

	defaults:
		_id: null
		artist: 'TestArtist'
		title: 'TestTitle'
		duration: 123
		audio_id: '-1_123123'
		#url: 'http://dl.dropbox.com/u/15505476/1.mp3'

class Playlists.Collections.TracksCollection extends Backbone.Collection
	model: Playlists.Models.Track
	#url: '/api/tracks'

	initialize: ->
		console.log 'Track collection ctreated'

	getThreeTracksForPlaying: ()->
		prev: @models[ @models.length-1 ] # модель последнего трека
		current: @models[0]
		next: @models[1]


