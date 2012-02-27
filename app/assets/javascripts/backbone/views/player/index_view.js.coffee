Playlists.Views.Player ||= {}
class Playlists.Views.Player.IndexView extends Backbone.View
	events:
		'click #prev_btn': 'prev'
		'click #play_btn': 'togglePause'
		'click #next_btn': 'next'

	initialize: ->
		console.log 'Player.IndexView init'
		@player = new Playlists.Models.Player()

	prev: ->
		@player.prev()

	togglePause: ->
		@player.togglePause()

	next: ->
		@player.next()

	# Загружаем в плеер треки из текущего плейлиста,
	# а трек по которому мы щелкнули сразу воспроизводим.
	# Если данный плейлист уже в плеере,
	# то ищем трек во в модели плеера.
	load_playlist_and_play_track: (e)->
		console.log e





