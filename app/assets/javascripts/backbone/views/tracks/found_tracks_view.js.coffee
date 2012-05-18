Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.FoundTracksView extends Backbone.View
  template: JST["backbone/templates/tracks/found_track"]

  initialize: (options) ->
    console.log 'Views.Tracks.FoundTracksView initialize()'
    @tracks = options

  render: ->
    console.log 'Views.Tracks.FoundTracksView render()'

    for track in @tracks
      # сохраняем данные для содания модели трека для передачи в плеер,
      # да, костыль, а что поделать.
      track.json = JSON.stringify track
      $(@el).append @template(track)

    this