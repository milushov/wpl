Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.ShowView extends Backbone.View
  template: JST["backbone/templates/playlists/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
