class Playlists.Models.Track extends Backbone.Model
  #paramRoot: 'track'
  initialize: ->

class Playlists.Collections.TracksCollection extends Backbone.Collection
  model: Playlists.Models.Track
  #url: '/api/tracks'

  initialize: ->

  getThreeTracksForPlaying: (id)->
    if !id
      prev: @models[ @models.length-1 ] # модель последнего трека
      current: @models[0]
      next: @models[1]
    else if id
      max_ind = @models.length - 1
      cur_ind =  @models.indexOf @getById(id)
      prev_ind = if cur_ind == 0 then max_ind else cur_ind - 1
      next_ind = if cur_ind == max_ind then 0 else cur_ind + 1
      
      prev: @models[cur_ind]
      current: @models[prev_ind]
      next: @models[next_ind]

  getById: (id)->
    ret = {}
    @each (model)->
      if model.get('_id') == id then ret = model
    return ret ? ret : false

