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

window.imgur = {}
window.imgur.api_url = 'http://api.imgur.com/2/upload.json'
window.imgur.key = 'f7efb1f4aa7bd05fdf3569e20e5b3759'

window.ondragover = (e) ->
  e.preventDefault()
  l 'ondragover'
window.ondrop = (e) ->
  e.preventDefault()
  App.vk.uploadImage e.dataTransfer.files[0]
  l 'ondrop'

$ ()->
  if my_profile == -1
    $("#app").html "<center><h1 style='font-size: 400px; margin-top: 250px;'>BAN</h1></center>"
    return false

  window.App = new Playlists.Routers.AppRouter(
    playlists: my_profile['playlists']
  )
  
  Backbone.history.start(pushState: true)

  bind_urls()
  
  soundManager.url = 'http://playlists.dev:3000';
  soundManager.preferFlash = true;
  soundManager.flashVersion = 9;
  soundManager.debugMode = if !debug then true
  soundManager.flashPollingInterval = 500
  #soundManager.useHighPerformance = true  
  #soundManager.html5PollingInterval = 33
  soundManager.defaultOptions = 
    #onpause:  ()-> App.player.model.pause()
    #onresume: ()-> App.player.model.resume()
    onfinish: ->
      App.player.model.next()
      42
    onload: ->
      App.player.model.loadNextTrack()
      42
    whileplaying: -> App.player.updatePlayProgress(this.position, this.duration)
    whileloading: -> App.player.updateLoadingProgress(this.bytesLoaded, this.bytesTotal)

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
    # console.error jqxhr.responseText
    if jqxhr.status == 403
      if JSON.parse(jqxhr.responseText).error == 'abuse'
        return alert 'Вы слишком часто обращаетесь к серверу, вы случайно не робот? Если да, то мы вас скоро забаним :-)'

    alert "Упс. Кажется эта ссылка сейчас не работает. Уже чиним. (#{exception})"
    #history.back()

  $('footer').tooltip
    selector: 'span[rel=tooltip]'
    placement: 'right'
    delay:
      show: 420, hide: 100

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
  console.log = ->
  console.warn = ->
  console.info = ->
  window.l = ->

window.curUrl = ()->
  $.url().attr().relative

window.bind_urls = ->
  $('a').click (event)->
    if $(this).data('type') != 'ext'
      event.preventDefault()
      url = $(this).attr('href');
      if url
        current_url = curUrl()
        if url != current_url
          loading();
          $('a[rel=tooltip]').tooltip('hide')
          #чтобы не мазолило глаза, если запрос будет ооочень долгий 
          setTimeout (->loading('off')), 15000
        
        if curUrl() == '/new' and App.need_ask
          if !confirm("#{my_profile.user.first_name}, вы уверены, что хотите покинуть страницу? Несохраненные данные потеряются!")
            return false
        App.navigate(url, true)


window.too_late = 0
window.loading = (ready = false) ->
  fast_operation = 10
  loader = $('#head_loader')
  if ready
    # console.warn "загрузилось", window.too_late
    # hide loader
    loader.fadeTo('fast', 0)
    window.too_late = 1
  else
    # console.warn "ждем #{fast_operation}", window.too_late
    # show loader
    setTimeout ()=>
      # if loader show,
      if loader.css('opacity') != '1' and not window.too_late
        # console.warn "быстрая операция < #{fast_operation}", window.too_late
        loader.fadeTo('fast', 1)
      else
        # console.warn "долгая операция > #{fast_operation}", window.too_late
      window.too_late = 0
    , fast_operation

window.dur = (dur)->
  min = (dur/60).toFixed(0)
  sec = if (dur%60).toString().length == 2 then "#{(dur%60)}" else "0#{(dur%60)}"
  "#{min}:#{sec}"

window.trackOver = (_this)->
  $(_this).find(".choose_track").show()

window.trackOut = (_this)->
  $(_this).find(".choose_track").hide()

window.playOnce = (_this)->
  json = $(_this).data 'track'
  track = new Playlists.Models.Track json
  App.player.playOnce track

window.chooseTrack = (_this)->
  json = $(_this).data 'track'
  track = new Playlists.Models.Track json
  App.new_tracks.add track
  App.new_playlist_view.trigger 'track_choosen'

window.make_playlist_url = (_this)->
  name = $(_this).val()
  $('#playlist_url').val(translitUrl(name))

window.translitUrl = (url)->
  az = {'а':'a', 'б':'b', 'в':'v', 'г':'g', 'д':'d', 'е':'e', 'ё':'e', 'ж':'zh', 'з':'z', 'и':'i', 'й':'y', 'к':'k', 'л':'l', 'м':'m', 'н':'n', 'о':'o', 'п':'p', 'р':'r', 'с':'s', 'т':'t', 'у':'u', 'ф':'f', 'х':'h', 'ц':'ts', 'ч':'ch', 'ш':'sh', 'щ':'sch', 'ъ':'', 'ь':'', 'ы':'y', 'э':'e', 'ю':'yu', 'я':'ya'}
  return url.toLowerCase()
    .replace(/ье|ьё/g, 'je')
    .replace(/ый/g, 'y')
    .replace(/[а-яё]/g, (m,k)->return az[m]) 
    .replace(/[^\w\d\s-_]+/g, '') 
    .replace(/[\s-_]+/g, '-')
    .replace(/(^-|-$)+/g,'')