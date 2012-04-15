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
			image: @model.get 'image'
			url: @model.get 'url'
		) )

		count_per_list = 2

		@model.tracks.each (track) =>
			return if count_per_list == 0
			$(@el).find('.tracks').append(new Playlists.Views.Tracks.TrackView(model: track).render().el)
			count_per_list -= 1
			
		return this
