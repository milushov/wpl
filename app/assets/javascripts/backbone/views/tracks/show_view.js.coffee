Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.ShowView extends Backbone.View
  template: JST["backbone/templates/tracks/show"]

  initialize: ->
  	console.log 'tracks/ShowView created'

  events :
    "click .actions .up a" : "voteUp"
    "click .actions .down a" : "voteDown"

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this

  voteUp: ->
  	console.log @, 'tracks/ShowView voteUp()'
  	#@model.voteUp()

  voteDown: ->
  	console.log @, 'tracks/ShowView voteDown()'
