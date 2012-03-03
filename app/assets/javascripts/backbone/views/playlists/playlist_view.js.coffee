Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.PlaylistView extends Backbone.View
	template: JST["backbone/templates/playlists/playlist"]

	events:
		"click .destroy" : "destroy"

	tagName: 'div'
	className: 'playlist'

	initialize: () ->
		#console.log 'Views.Playlists.PlaylistView initialize(@options)'
		@model = @options.model
		@options = null
		$(@el).attr 'id', 'playlistId_'+@model.get '_id'

	destroy: () ->
		@model.destroy()
		this.remove()
		return false

	render: ->
		$(@el).html( @template(
			name: @model.get 'name'
			description: @model.get 'description'
			tags: @model.get 'tags'
		) )

		@model.tracks.each (track) =>
			$(@el).find('.tracks').append( new Playlists.Views.Tracks.TrackView(model: track).render().el )
			
		return this
