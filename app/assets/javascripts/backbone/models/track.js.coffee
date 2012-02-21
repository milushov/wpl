class Playlists.Models.Track extends Backbone.Model
  paramRoot: 'track'

  defaults:
    track_id: null
    artist: null
    title: null
    audio_id: null

class Playlists.Collections.TracksCollection extends Backbone.Collection
  model: Playlists.Models.Track
  url: '/api/tracks'
