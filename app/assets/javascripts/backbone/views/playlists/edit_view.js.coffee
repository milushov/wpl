Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.EditView extends Backbone.View
  template: JST["backbone/templates/playlists/edit"]

  events:
    'click #track_seacher a' : 'addTrack'
    'click #save_playlist' : 'savePlaylist'

  initialize: () ->
    @model = @options
    App.new_tracks = new Playlists.Collections.TracksCollection()

    @.on 'track_choosen', -> @updateTracks()
    @.on 'image_uploaded', (image_data)-> @imageUploaded(image_data)

  addTrack: ->
    track_name = $('#track_seacher input').val()
    if track_name.length < 2
      return notify 'Название трека слишком короткое'

    App.vk.searchTracks track_name, 0, (data)->
      if data.error
        return notify data.error.error_msg + ' Перезагрузите страничку (F5)'
      if data.response.tracks
        data.response.tracks.splice 0, 1 # remove first element
      tracks = data.response.tracks
      
      return notify 'Ни одного трека не найдено' unless tracks
        
      @$('#searched_tracks').html(
        new Playlists.Views.Tracks.FoundTracksView(tracks).render().el
      )
    ,this

  updateTracks: ->
    App.need_ask = true
    # $('#tracks').empty()
    track = App.new_tracks.models[App.new_tracks.models.length-1]
    track.set audio_id: "#{track.get "owner_id"}_#{track.get "aid"}"
    track.set artist_photo: '/assets/default.jpg'
    $('#tracks').append(
      new Playlists.Views.Tracks.TrackView(model: track).render().el
    )
    $('#searched_tracks').empty()

  savePlaylist: ->
    console.log 'Views.Playlists.NewView savePlaylist()'
    return notify 'Добавьте хоть один трек' unless App.new_tracks.models
    # remove attributes that are not needed in the database
    for track in App.new_tracks.models
      track.unset 'lyrics_id'
      track.unset 'url'
      track.unset 'owner_id'
      track.unset 'aid'

    pid = @model.get '_id'
    App.vk.editPlaylist pid, App.new_tracks.toJSON(), (data) ->
      return notify data.error if data.error
      # removing this playlist from our cash
      p = App.playlists.getById pid
      i = App.playlists.models.indexOf p
      console.log i
      delete App.playlists.models[i]
      App.playlists.models.length -= 1
      App.navigate(data.id, true) if data.status  
    ,this

  render: ->    
    url = @model.get 'url'
    i_follow = false
    if my_profile.playlists.length != 0
      i_follow = p for p in my_profile.playlists when p.url == url

    playlist_data = @model.toJSON()
    playlist_data.comments_url = "/#{@model.get 'url'}/comments"
    playlist_data.i_follow = i_follow
    $(@el).html @template(playlist_data)

    # adding playlist's id in track model for player needs
    pid = @model.get('_id')

    tracks_block = $(@el).find('#tracks')
    my_id = my_profile.user.id
    for i,track of @model.tracks.models
      track.set(playlist_id: pid)
      # if we hate this track, it will be not rendered
      if track.get('haters').indexOf(my_id) == -1
        tracks_block.append( new Playlists.Views.Tracks.TrackView(model: track).render().el )

    this
