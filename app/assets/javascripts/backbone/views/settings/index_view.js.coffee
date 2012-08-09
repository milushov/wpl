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
      return lastfm.settings.get_auth_token()
    else
      clear_lastfm_session()

    @render()
    
  render: ->
    console.log 'Settings.IndexView render', @el
    $(@el).html @template(
      lastfm_enable: @lastfm,
      lastfm_name: lastfm.settings.session_name
    )
    this