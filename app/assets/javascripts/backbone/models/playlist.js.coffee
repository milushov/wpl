class Playlists.Models.Playlist extends Backbone.Model
  defaults:
    playlist_id: null
    name: null
    description: null
    tags: null

  initializer:  ->
    console.log( 'Playlist model created' )
 

class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/api/playlists'
