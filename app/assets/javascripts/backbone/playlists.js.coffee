#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Playlists =
	Models: {}
	Collections: {}
	Routers: {}
	Views: {}
	init: ->
		console.log('hello')
		

$(document).ready ->
	window.Playlists.init()