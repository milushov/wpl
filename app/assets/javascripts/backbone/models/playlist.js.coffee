class P.Models.Playlist extends Backbone.Model
  paramRoot: 'playlist'

  defaults:
    name: null
    description: null
    tags: null

class P.Collections.PlaylistsCollection extends Backbone.Collection
  model: P.Models.Playlist
  url: '/playlists'
