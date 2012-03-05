class Playlists.Models.Player extends Backbone.Model
	defaults:
		state: 'pause'
		prevTrack: null
		currentTrack: null
		nextTrack: null

	initialize: ->
		console.log 'Player model created'

	reset: ->
		soundManager.reboot()

	loadAndPlay: (current_tracks)->
		@current_tracks = current_tracks
		ids = [
			@current_tracks.prev.get('audio_id')
			@current_tracks.current.get('audio_id')
			@current_tracks.prev.get('audio_id')
		]

		App.vk.getThreeTrackData ids, (data)=>
			data = data.response
			cur_tracks = App.player.current_tracks
			if !data.prev then @urlSrcError() else
				cur_tracks.prev.set url: data.prev.url
				cur_tracks.prev.set lyrics_id: data.prev.lyrics_id
			if !data.current then @urlSrcError() else
				cur_tracks.current.set url: data.current.url
				cur_tracks.current.set lyrics_id: data.current.lyrics_id
			if !data.next then @urlSrcError() else
				cur_tracks.next.set url: data.next.url
				cur_tracks.next.set lyrics_id: data.next.lyrics_id

			App.player.set prevTrack: cur_tracks.prev
			App.player.set currentTrack: cur_tracks.current
			App.player.set nextTrack: cur_tracks.next

			App.player.get('currentTrack').set sound: soundManager.createSound
				id: cur_tracks.prev.get '_id'
				url: cur_tracks.prev.get 'url'
				onpause: ()->
					App.player.trigger("changed")
				onresume: ()->
					App.player.trigger("changed")
				onfinish: ()->
					App.player.trigger("changed")

			App.player.play()

	play: ()->
		currentTrack = @get('currentTrack')
		l currentTrack
		currentTrack.get('sound').play( @get('currentTrack').get('_id') )

	render: ->
		console.log 'render'

	prev: ->
		console.log 'prev'

	togglePause: ->
		currentTrack = @get('currentTrack').get('sound').togglePause()

	next: ->
		console.log 'next'

	urlSrcError: ()->
		alert 'o_O Вы нашли очень редкую ошибку. Экземпляр данного трека был удален из VK.'