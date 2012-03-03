Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
	template: JST["backbone/templates/tracks/track"]

	events :
		"click .actions .up a" : "voteUp"
		"click .actions .down a" : "voteDown"
		"click .destroy" : "destroy"

	tagName: 'div'
	className: 'track'

	initialize: () ->
		console.log 'Views.Tracks.TrackView initialize(@options)', @options, $ @el
		@model = @options.model
		@options = null
		$(@el).attr 'id', 'trackId_'+@model.get '_id'

	voteUp: ->
		console.log 'Views.Tracks.TrackView voteUp()'
		#@model.voteUp()

	voteDown: ->
		console.log 'Views.Tracks.TrackView voteDown()'

	destroy: () ->
		@model.destroy()
		this.remove()
		return false

	render: ->
		console.log 'Views.Tracks.TrackView render()'
		$(@el).html( @template( @model.toJSON() ) )
		return this
