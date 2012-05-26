class Playlists.Models.Playlist extends Backbone.Model
  url: ->
    if url = @get('url')
      "/api/playlists/#{url}"
    else
      false

  initialize: (options)->
    # console.log 'Models.Playlist initialize()', options
    @tracks = @nestCollection('tracks', new Playlists.Collections.TracksCollection(options.tracks))

    @comments = @nestCollection('comments', new Playlists.Collections.CommentsCollection())


class Playlists.Collections.PlaylistsCollection extends Backbone.Collection
  model: Playlists.Models.Playlist
  url: '/api/playlists'

  initialize: (options)->
    # console.log 'Collections.PlaylistsCollection initialize()', options

  getByUrl: (url)->
    ret = null
    @each (model)->
      if model.get('url') == url then ret = model
    return ret

  getById: (id)->
    ret = null
    @each (model)->
      if model.get('_id') == id then ret = model
    return ret