Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
  template: JST["backbone/templates/tracks/track"]

  events :
    'click .play_btn' : 'play'
    'click .up a' : 'voteUp'
    'click .down a' : 'voteDown'
    'click .destroy' : 'destroy'

  tagName: 'div'
  className: 'track'

  initialize: () ->
    @model = @options.model
    @options = null
    $(@el).attr 'id', "track_id-#{ @model.get("_id") }"

  play: ->
    console.log 'Views.Tracks.TrackView play()', @

    # !!! Придумать как записать каждому треку атрибут - playlist_url
    #playlist_url = @model.get('playlist_url')
    playlist_url = 'test1'
    audio_id = $(@el).find('.play_btn').data('audio_id')

    if playlist_url == curUrl().substr(1)
      App.player.loadAndPlay(null, audio_id)
    else  
      App.player.loadAndPlay(
        App.playlists.getByUrl(playlist_url),
        audio_id
      )

  voteUp: ->
    console.log 'Views.Tracks.TrackView voteUp()'
    @model.voteUp()

  voteDown: ->
    console.log 'Views.Tracks.TrackView voteDown()'
    @model.voteDown()

  destroy: () ->
    @model.destroy()
    this.remove()
    return false

  render: ->
    #console.log 'Views.Tracks.TrackView render()'
    $(@el).html( @template( @model.toJSON() ) )
    return this
