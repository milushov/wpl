Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.NewView extends Backbone.View
  template: JST["backbone/templates/playlists/new"]

  tagName: 'div'

  events:
    'click #track_seacher a' : 'addTrack'
    'click #save_playlist' : 'savePlaylist'

  initialize: (options) ->
    console.log 'Views.Playlists.NewView initialize()', options
    @me = options.me

    App.new_tracks = new Playlists.Collections.TracksCollection()

    @.on 'track_choosen', -> @updateTracks()
    @.on 'image_uploaded', (image_data)-> @imageUploaded(image_data)

  addTrack: ->
    console.log 'Views.Playlists.NewView addTrack()'

    track_name = $('#track_seacher input').val()
    if track_name.length < 3
      alert 'Название трека слишком короткое'
      return

    App.vk.searchTracks track_name, 0, (data)->
      data.response.tracks?.splice 0, 1 # убираем первый элемент, который содержит кол-во найденных треков
      window.a = tracks = data.response.tracks
      if not tracks?
        alert 'ни одного трека не найдено'
        return
      $('#searched_tracks').html(new Playlists.Views.Tracks.FoundTracksView(tracks).render().el)
    ,this

  updateTracks: ->
    App.need_ask = true
    $('#tracks').empty()
    for track in App.new_tracks.models
      track.set audio_id: "#{track.get "owner_id"}_#{track.get "aid"}"
      track.set artist_photo: '/assets/default.jpg'
      $('#tracks').append(new Playlists.Views.Tracks.TrackView(model: track).render().el)
    $('#searched_tracks').empty()

  savePlaylist: ->
    console.log 'Views.Playlists.NewView savePlaylist()'
    
    for track in App.new_tracks.models
      track.unset 'lyrics_id'
      track.unset 'url'
      track.unset 'owner_id'
      track.unset 'aid'

    new_playlist = 
      name: $('#playlist_name').val()
      url: $('#playlist_url').val()
      image:  'http://vk.com/images/camera_a.gif'
      description: $('#playlist_description').val()
      tags: $("#edit_tags").tagit("assignedTags")
      creator: my_profile.user.id
      tracks: App.new_tracks.toJSON()

    new_playlist = JSON.stringify new_playlist

    App.vk.saveNewPlaylist playlist: new_playlist, (data)->
      if data.status
        App.navigate(data.id, true)
      else
        alert 'что-то пошло не так'
    , this

  imageUploaded: (imageUploaded) ->
    console.log imageUploaded
    @image = imageUploaded
    $('#photo img')[0].src = @image.upload.links.large_thumbnail

  render: ->
    console.log 'Views.Playlists.NewView render()'

    $(@el).html @template(
      photo: @me.photo
      screen_name: @me.screen_name
    )

    #this.$("form").backboneLink(@model)
    this