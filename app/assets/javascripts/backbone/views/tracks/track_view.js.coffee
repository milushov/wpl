Playlists.Views.Tracks ||= {}

class Playlists.Views.Tracks.TrackView extends Backbone.View
  template: JST['backbone/templates/tracks/track']

  events :
    'mouseover' : 'showVoteButtons'
    'mouseout' : 'hideVoteButtons'
    # 'click' : 'play' # FIXME нужно что-то придумать! 
    'click .play_btn' : 'play'
    'click .up a'     : 'like'
    'click .down a'   : 'hate'
    'click .destroy'  : 'destroy'

  tagName: 'div'
  className: 'track'

  initialize: () ->
    @model = @options.model
    @options = null
    $(@el).attr 'id', "track_id-#{ @model.get("_id") }"
    $(@el).css 'cursor', 'pointer'

  showVoteButtons: ->
    $(@el).find('.lovers').hide()
    $(@el).find('.actions').show()

  hideVoteButtons: ->
    $(@el).find('.lovers').show()
    $(@el).find('.actions').hide()

  play: ->
    console.log 'Views.Tracks.TrackView play()', @model
    App.player.play @model

  like: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'

    App.vk.vote 'like', pid, tid, (data) ->
      if data.error
        return notify 'Вы уже голосовали за этот трек!'

      track = App.playlists.getById(pid).tracks.where(_id: tid)[0]
      track.get('lovers').pop()
      track.get('lovers').splice 0, 0, my_profile.user
      track.set real_lovers_count: track.get('real_lovers_count') + 1

      notify "Вы проголосовали за <b>#{ @model.get('title') }</b>", 'success'

      # here is will be implemented beautiful animation
      console.log $(@el).html( @template( @model.toJSON() ) )
    ,this

  hate: ->
    pid = @model.get 'playlist_id'
    tid = @model.get '_id'
    
    # deleting banned track from playlists store
    playlist = App.playlists.getById(pid)
    track = playlist.tracks.getById tid
    ind = playlist.tracks.models.indexOf track
    playlist.tracks.models.splice ind, 1
    console.log ind

    # and from current playlist..
    # but no need to remove, because it javasctipt!
    
    #track.get('haters').push my_profile.user.id
    #track.set real_haters_count: track.get('real_haters_count') + 1
    $(@el).slideUp 500, 'easeOutExpo', -> ( $(this).remove())
    # @destroy # don't working! 
    notify "Данный трек <b>#{ @model.get('title') }</b> больше не будет вам попадаться", 'success'
    $('.tooltip').remove() # for prevent bug, when after click tooltip countinue to be displayed
    # @destroy if not App.settings.show_hidden_tracks

    App.vk.vote 'hate', pid, tid, (data)->
      unless data.status
        notify 'Упс. Что-то пошло не так. Запрос не прошел..'
    ,this

  destroy: ->
    @model.destroy()
    this.remove()
    return false

  render: ->
    #console.log 'Views.Tracks.TrackView render()'
    $(@el).html( @template( @model.toJSON() ) )
    return this
