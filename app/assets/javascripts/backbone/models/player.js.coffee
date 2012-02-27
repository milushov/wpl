class Playlists.Models.Player extends Backbone.Model
	defaults:
		state: 'pause'
		prevTrack: null # объекты SMSound
		currentTrack: null
		nextTrack: null

	initialize: ->
		console.log 'Player model created'

	reset: ->
		soundManager.reboot()
		set
			state: 'pause'
			prevTrack: null # объекты SMSound
			currentTrack: null
			nextTrack: null

	render: ->
		console.log 'render'

	prev: ->
		console.log 'prev'

	togglePause: ->
		console.log 'togglePause'		

	next: ->
		console.log 'next'		