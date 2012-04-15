class Playlists.Models.Playlist extends Backbone.Model
  initialize: (options)->
    # console.log 'Models.Playlist initialize()', options
    @tracks = @nestCollection('tracks', new Playlists.Collections.TracksCollection(options.tracks))


class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/api/playlists'

  initialize: (options)->
    # console.log 'Collections.PlaylistsCollection initialize()', options

  getByUrl: (url)->
    ret = false
    @each (model)->
      if model.get('url') == url then ret = model
    return ret