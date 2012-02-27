class Playlists.Models.Playlist extends Backbone.Model
  defaults:
    _id: null
    name: null
    description: null
    tags: null

  initialize: (options)->
    console.log( 'Playlist model created' )
    #@tracks = new Playlists.Collections.TracksCollection( options.tracks )
    @tracks = @nestCollection('tracks', new Playlists.Collections.TracksCollection(options.tracks))
 

class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/api/playlists'
