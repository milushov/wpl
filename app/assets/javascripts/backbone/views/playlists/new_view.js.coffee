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
      return notify 'Название трека слишком короткое'

    App.vk.searchTracks track_name, 0, (data)->
      if data.response.tracks
        data.response.tracks.splice 0, 1 # remove first element
      tracks = data.response.tracks
      
      return notify 'Ни одного трека не найдено' unless tracks
        
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

    tags = $("#edit_tags").tagit("assignedTags")
    if tags.length == 0
      return notify 'Добавьте хоть один тег'

    description = $('#playlist_description').val()
    if description.length < 10
      return notify 'Описание слишком короткое'

     
    switch count = App.new_tracks.length
      when 0 then return notify 'Добавьте треков в плейлист'
      when 1, 2 then return notify 'Маловато треков для плейлиста'

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
    # console.log imageUploaded
    @image = imageUploaded.upload.links
    $('#photo img')[0].src = @image.large_thumbnail

  render: ->
    console.log 'Views.Playlists.NewView render()'

    $(@el).html @template(
      photo: @me.photo
      screen_name: @me.screen_name
    )

    #this.$("form").backboneLink(@model)
    this