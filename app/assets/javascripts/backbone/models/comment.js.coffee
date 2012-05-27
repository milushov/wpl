class Playlists.Models.Comment extends Backbone.Model
  idAttribute: "_id"
  #paramRoot: 'comment'
  url: ->
    "/api/playlists/#{@get('playlist_id')}/comments/#{@get('id')}"

class Playlists.Collections.CommentsCollection extends Backbone.Collection
  model: Playlists.Models.Comment
  # url will be defained, when collection will be populate with models
  
  initialize: (options) ->
    # console.log 'collection comments created'
    # TODO: выбирить по id-шнику, а не по url
    # options.model.get 'url'
