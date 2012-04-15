class Playlists.Models.Playlist extends Backbone.Model
  defaults:
    _id: null
    name: null
    image: null
    description: null
    tags: null
    url: null
    creator: null

  initialize: (options)->
    console.log 'Playlists.Models.Playlist initialize()', @options
    @tracks = @nestCollection('tracks', new Playlists.Collections.TracksCollection(options.tracks))


class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/api/playlists'

  initialize: ()->
    console.log 'Playlists.Collections.PlaylistsCollection initialize()', @options

  getByUrl: (url)->
    ret = false
    @each (model)->
      if model.get('url') == url then ret = model
    return ret