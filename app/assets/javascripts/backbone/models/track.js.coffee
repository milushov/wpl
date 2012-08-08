class Playlists.Models.Track extends Backbone.Model
  #paramRoot: 'track'
  default:
    playlist_id: '0'
    
  initialize: ->

  getName: () ->
    "#{@get('artist')} – #{@get('title')}"

  # special double id for SoundManager
  smid: ->
    if @get('playlist_id')?
      "smid_#{@get 'playlist_id'}"
    else
      false

class Playlists.Collections.TracksCollection extends Backbone.Collection
  model: Playlists.Models.Track
  #url: '/api/tracks'

  initialize: (options) ->

  getFirst: ->
    @models[0]

  getNext: (id) ->
    if id
      max_ind = @models.length - 1
      cur_ind =  @models.indexOf @getById(id)
      next_ind = if cur_ind == max_ind then 0 else cur_ind + 1
      @models[next_ind]
    else
      @models[0]

  getPrev: (id) ->
    if id
      max_ind = @models.length - 1
      cur_ind =  @models.indexOf @getById(id)
      prev_ind = if cur_ind == 0 then max_ind else cur_ind - 1
      @models[prev_ind]
    else
      @models[0]

  getById: (id) ->
    ret = null
    @each (model) ->
      if model.get('_id') == id or model.get('audio_id') == id then ret = model
    ret

  get3Tracks: (id) ->
    if !id
      prev: @models[ @models.length-1 ] # модель последнего трека
      current: @models[0]
      next: @models[1]
    else if id
      max_ind = @models.length - 1
      cur_ind =  @models.indexOf @getById(id)
      prev_ind = if cur_ind == 0 then max_ind else cur_ind - 1
      next_ind = if cur_ind == max_ind then 0 else cur_ind + 1
      
      prev: @models[prev_ind]
      current: @models[cur_ind]
      next: @models[next_ind]


