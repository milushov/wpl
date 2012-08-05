Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.NewView extends Backbone.View
  template: JST["backbone/templates/playlists/new"]

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
    track_name = $('#track_seacher input').val()
    if track_name.length < 2
      return notify 'Название трека слишком короткое'

    loading()

    App.vk.searchTracks track_name, 0, (data)->
      if data.response?.tracks
        data.response.tracks.splice 0, 1 # remove first element
      else if data.error?
        notify "#{data.error.error_msg} #{data.error.error_code}"
        if data.error.error_code is 5
          App.vk.logout()
          #location.reload()

      tracks = data.response.tracks
      
      return notify 'Ни одного трека не найдено' and loading('off') unless tracks

      lastfm.api.artist_info tracks[0].artist, (data) =>
        if data.artist? and data.artist.image[1]['#text'] isnt ''
          artist_photo = data.artist.image[1]['#text']
        else
          # lastfm.api.track_info tracks[0].artist, tracks[0].title, (data) =>
            # console.log data

        for track in tracks
          track.artist_photo = artist_photo || '/assets/default.jpg'

        @$('#searched_tracks').html(
          new Playlists.Views.Tracks.FoundTracksView(tracks).render().el
        )

        @$('#searched_tracks').show()
        
        loading('off')

    ,this

  updateTracks: ->
    App.need_ask = true
    $('#tracks').empty()
    for track in App.new_tracks.models
      track.set audio_id: "#{track.get "owner_id"}_#{track.get "aid"}"
      # track.set artist_photo: '/assets/default.jpg'
      $('#tracks').append(
        new Playlists.Views.Tracks.TrackView(model: track).render().el
      )
      l track
    $('#searched_tracks').empty()

  savePlaylist: ->
    console.log 'Views.Playlists.NewView savePlaylist()'
    
    # remove attributes that are not needed in the database
    for track in App.new_tracks.models
      track.unset 'lyrics_id'
      track.unset 'url'
      track.unset 'owner_id'
      track.unset 'aid'

    name = $('#playlist_name').val()
    if name.length < 3
      return notify 'Слишком короткое название'

    url = $('#playlist_url').val()
    if name.length < 3
      return notify 'Ссылка слишком короткая'

    if not @image
      return notify 'Загрузите изображение, визуализирующее тематику плейлиста'
    image = 
      image: @image.large_thumbnail
      image_small: @image.small_square

    delete @image

    tags = $("#edit_tags").tagit("assignedTags")
    if tags.length == 0
      return notify 'Добавьте хоть один тег'

    description = $('#playlist_description').val()
    if description.length < 10
      return notify 'Описание слишком короткое'

    switch count = App.new_tracks.length
      when 0 then return notify 'Добавьте треков в плейлист'
      when 1, 2, 3, 4 then return notify 'Маловато треков для плейлиста, нужно минимум 5'

    new_playlist = 
      name: name
      url: url
      image:  image
      description: description
      tags: tags
      creator: my_profile.user.id
      tracks: App.new_tracks.toJSON()

    new_playlist = JSON.stringify new_playlist

    App.vk.saveNewPlaylist playlist: new_playlist, (data) ->
      return notify data.error if data.error
      App.navigate(data.id, true) if data.status  
    ,this

  imageUploaded: (imageUploaded) ->
    l window.roma = imageUploaded
    if imageUploaded.upload.image.animated == 'true'
      return notify 'Давайте не загружать анимашки :-)'
    @image = imageUploaded.upload.links
    $('#photo img')[0].src = @image.large_thumbnail
    loading('off')

  render: ->
    $(@el).html @template(@me)

    this