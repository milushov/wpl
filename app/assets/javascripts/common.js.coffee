Backbone.Model::nestCollection = (attributeName, nestedCollection) ->
  #setup nested references
  for item, i in nestedCollection
    @attributes[attributeName][i] = nestedCollection.at(i).attributes

  #create empty arrays if none
  nestedCollection.bind 'add', (initiative) =>
    if !@get(attributeName)
      @attributes[attributeName] = []
    @get(attributeName).push(initiative.attributes)

  nestedCollection.bind 'remove', (initiative) =>
    updateObj = {}
    updateObj[attributeName] = _.without(@get(attributeName), initiative.attributes)
    @set(updateObj)

  nestedCollection

window.debug = 1

window.l = (a, b)->
  if not a or arguments.length == 0 then return 'not arguments'
  if arguments.length > 2
    console.log(arguments);
  else
    if b
      console.log(a, b)
    else
      console.log(a)

if not debug
  console.log = ()->
  console.warn = ()->
  console.info = ()->
  window.l = ()->

window.curUrl = ()->
  $.url().attr().relative

window.bind_urls = ()->
  $('a').click (event)->
    if $(this).data('type') != 'ext'
      event.preventDefault()
      url = $(this).attr('href');
      if url
        current_url = curUrl()
        if url != current_url
          loading();
          #чтобы не мазолило глаза, если запрос будет ооочень долгий 
          setTimeout (()->loading('off')), 15000
        App.navigate(url, true)


window.too_late = 0
window.loading = (ready = false) ->
  fast_operation = 10
  loader = $('#head_loader')
  if ready
    console.warn "загрузилось", window.too_late
    # hide loader
    loader.fadeTo('fast', 0)
    window.too_late = 1
  else
    console.warn "ждем #{fast_operation}", window.too_late
    # show loader
    setTimeout ()=>
      # if loader show,
      if loader.css('opacity') != '1' and not window.too_late
        console.warn "быстрая операция < #{fast_operation}", window.too_late
        loader.fadeTo('fast', 1)
      else
        console.warn "долгая операция > #{fast_operation}", window.too_late
      window.too_late = 0
    , fast_operation

$ ()->
  window.App = new Playlists.Routers.AppRouter(
    playlists: my_profile['playlists']
  )
  
  Backbone.history.start(pushState: true)

  bind_urls()
  
  soundManager.url = 'http://playlists.dev:3000';
  soundManager.preferFlash = true;
  soundManager.flashVersion = 9;
  soundManager.debugMode = if debug then true
  #soundManager.flashPollingInterval = 330
  soundManager.useHighPerformance = true  
  #soundManager.html5PollingInterval = 33
  soundManager.defaultOptions = 
    onpause:  ()-> App.player.trigger("pause")
    onresume: ()-> App.player.trigger("resume")
    onfinish: ()-> App.player.trigger('next')
    onload: ()->
    onfinish: ()->
    whileplaying: ()-> App.player.updatePlayProgress(this.position, this.duration)
    whileloading: ()-> App.player.updateLoadingProgress(this.bytesLoaded, this.bytesTotal)

  # достасть из localStorage
  default_volume = 100
  duration_mode = 'pos'

  soundManager.defaultOptions.volume = default_volume;
  
  soundManager.onready ()->
    App.player = new Playlists.Views.Player.IndexView(
      model: new Playlists.Models.Player(duration_mode: duration_mode)
    )

  soundManager.ontimeout ()->
    alert 'Плеер завис, перезагрузите страницу! (F5)'

  $(document).ajaxError (e, jqxhr, settings, exception) =>
    console.error arguments
    alert "Упс. Кажется эта ссылка сейчас не работает. Уже чиним. (#{exception})"
    history.back()

