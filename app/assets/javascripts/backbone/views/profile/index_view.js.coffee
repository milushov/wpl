Playlists.Views.Profile ||= {}

class Playlists.Views.Profile.IndexView extends Backbone.View
  template: JST["backbone/templates/profile/profile"]

  initialize: () ->
    console.log 'Profile.IndexView nitialize()'

  settings: () ->
    console.log 'Profile.IndexView settings'

  render: =>
    console.log 'Profile.IndexView render', @el
    $( @el ).html( @template() )
    return this
