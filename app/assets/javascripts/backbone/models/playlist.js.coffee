class Playlists.Models.Playlist extends Backbone.Model
  paramRoot: 'playlist'

  defaults:
    name: null
    description: null
    tags: null
    
  initializer:  ->
    console.log( 'Playlist model start' )
 

class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/playlists'
