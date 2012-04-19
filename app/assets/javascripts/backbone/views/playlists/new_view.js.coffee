Playlists.Views.Playlists ||= {}

class Playlists.Views.Playlists.NewView extends Backbone.View
  template: JST["backbone/templates/playlists/new"]

  tagName: 'div'

  events:
    "submit #new-playlist": "save"
    'click #add_track' : 'addTrack'
    'click #save_playlist' : 'savePlaylist'

  initialize: (options) ->
    console.log 'Views.Playlists.NewView initialize()', options
    @me = options.me
    #super(options)
    #@model = new @collection.model()

    #@model.bind("change:errors", () =>
    #  this.render()
    #)

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (playlist) =>
        @model = playlist
        window.location.hash = "/#{@model.id}"

      error: (playlist, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  addTrack: ->
    console.log 'Views.Playlists.NewView addTrack()'

  savePlaylist: ->
    console.log 'Views.Playlists.NewView savePlaylist()'    

  render: ->
    console.log 'Views.Playlists.NewView render()'

    $(@el).html @template(
      photo: @me.photo
      screen_name: @me.screen_name
    )

    

    #this.$("form").backboneLink(@model)
    @