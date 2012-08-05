Playlists.Views.Settings ||= {}

class Playlists.Views.Settings.IndexView extends Backbone.View
  template: JST['backbone/templates/settings/index']

  events:
    'click .lastfm' : 'toggleLastfm'

  initialize: (options) ->
    console.log 'Settings.ShowView nitialize()'
    @lastfm = my_profile.settings.lastfm.enable

  toggleLastfm: ->
    @lastfm = !@lastfm
    my_profile.settings.lastfm.enable = !@lastfm

    if @lastfm
      return location.href = lastfm.settings.auth_url()
    else
      delete lastfm.settings.session_key
      delete lastfm.settings.session_name

      delete localStorage.session_key
      delete localStorage.session_name

    @render()
    
  render: =>
    console.log 'Settings.IndexView render', @el
    $(@el).html @template(
      lastfm_enable: @lastfm,
      lastfm_name: lastfm.settings.session_name
    )
    this