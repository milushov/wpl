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

window.imgur = {}
window.imgur.api_url = 'http://api.imgur.com/2/upload.json'
window.imgur.key = 'f7efb1f4aa7bd05fdf3569e20e5b3759'

# moment foemat for created_at property of comment
window.format = 'D MMMM YYYY, H:mm, dddd'
window.lite_format = 'D MMMM, H:mm'

window.dative = (full_name) ->
  rn = new RussianName(full_name)
  rn.fullName rn.gcaseDat

window.ondragover = (e) ->
  e.preventDefault()
  l 'ondragover'
window.ondrop = (e) ->
  e.preventDefault()
  App.vk.uploadImage e.dataTransfer.files[0]
  l 'ondrop'

# alert, success, error, information and confirmation
window.notify = (message, type = 'error', long_message = false) ->
  timeout = if long_message then 15000 else 4500
  noty(
    text: message,
    theme:'noty_theme_twitter',
    layout: if type == 'error' then 'topRight' else 'bottomRight',
    type: type,
    animateOpen:
      height: 'toggle'
    animateClose: 
      height: 'toggle',
    easing: 'easeOutExpo',
    speed: 500,
    timeout: timeout,
    closeButton:true,
    closeOnSelfClick: true,
    closeOnSelfOver: false,
    modal: if type == 'error' then true else false
  )

window.l = (a, b)->
  if not a or arguments.length == 0 then return 'not arguments'
  if arguments.length > 2
    console.log(arguments);
  else
    if b
      console.log(a, b)
    else
      console.log(a)

window.title = (mes = 404) ->
  document.title = mes

window.curUrl = (what) ->
  switch what
    when 'playlist' then return $.url().segment(1)
    when 'track' then return $.url().param('track')
    when 'user' then return $.url().segment(2)
    else return false
  

window.bind_urls = ->
  $('a').click (event)->
    if $(this).data('type') != 'ext'
      event.preventDefault()
      url = $(this).attr('href');
      if url
        current_url = curUrl()
        if url != current_url
          loading()
          $('a[rel=tooltip]').tooltip('hide')
          #чтобы не мазолило глаза, если запрос будет ооочень долгий 
          setTimeout (->loading('off')), 15000
        
        if curUrl() == '/new' and App.need_ask
          if !confirm("#{my_profile.user.first_name}, вы уверены,
            что хотите покинуть страницу? Несохраненные данные потеряются!")
            return false
        App.navigate(url, true)

window.nav = (_this) ->
  url = $(_this).attr 'href'
  return App.navigate url, true

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
    setTimeout () =>
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
  audio_id = "#{track.get "owner_id"}_#{track.get "aid"}"
  if res = App.new_tracks.where('audio_id': audio_id)
    if res.length
      name = "#{res[0].get('artist')} - #{res[0].get('title')}"
      return notify "Этот трек <b>#{name}</b> уже есть в плейлисте"
  App.new_tracks.add track
  App.new_playlist_view?.trigger 'track_choosen'
  App.edit_playlist_view?.trigger 'track_choosen'

  count = App.new_tracks.length
  $('#progress_tracks .bar').width "#{count*20}%"

window.make_playlist_url = (_this)->
  name = $(_this).val()
  $('#playlist_url').val(translitUrl(name))

window.translitUrl = (url)->
  az = {
    'а':'a', 'б':'b', 'в':'v', 'г':'g', 'д':'d',
    'е':'e', 'ё':'e', 'ж':'zh', 'з':'z',
    'и':'i', 'й':'y', 'к':'k', 'л':'l',
    'м':'m', 'н':'n', 'о':'o', 'п':'p',
    'р':'r', 'с':'s', 'т':'t', 'у':'u',
    'ф':'f', 'х':'h', 'ц':'ts', 'ч':'ch',
    'ш':'sh', 'щ':'sch', 'ъ':'', 'ь':'',
    'ы':'y', 'э':'e', 'ю':'yu', 'я':'ya'
  }
  return url.toLowerCase()
    .replace(/ье|ьё/g, 'je')
    .replace(/ый/g, 'y')
    .replace(/[а-яё]/g, (m,k)->return az[m]) 
    .replace(/[^\w\d\s-_]+/g, '') 
    .replace(/[\s-_]+/g, '-')
    .replace(/(^-|-$)+/g,'')

window.linkify = (text) ->
  exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
  text.replace(exp,"<a href='$1' data-type='ext' target='blank'>$1</a>")

window.can_update = (time_str) ->
  return false unless time_str
  diff = (moment().diff(time_str)/1000).toFixed()
  max_time = 4*60*60
  return if diff > max_time then false else true

window.show_ban_info = () ->
  return $("#app").html "
  <center>
    <h1 style='font-size: 400px; margin-top: 250px;'>
      BAN
    </h1>
  </center>"

window.soundManagerSetup = ->
  ####### soundManager settings #######
  soundManager.url = "#{api_url}swf/"
  soundManager.waitForWindowLoad = true
  soundManager.debugMode = false #if !debug then true
  
  soundManager.preferFlash = true;
  soundManager.flashVersion = 9;

  soundManager.useHighPerformance = true

  soundManager.html5PollingInterval = 33
  soundManager.flashPollingInterval = 33

  soundManager.defaultOptions = 
    onfinish: -> App.player.model.next()
    onload: -> App.player.model.loadNextTrack()
    whileplaying: -> App.player.updatePlayProgress this.position, this.duration
    whileloading: -> App.player.updateLoadingProgress this.bytesLoaded, this.bytesTotal

  # достасть из localStorage

  volume = $.cookie('volume') || 100
  dur_mode = $.cookie('duration_mode') || 'pos'

  soundManager.defaultOptions.volume = volume;
  
  soundManager.onready ->
    App.player = new Playlists.Views.Player.IndexView(
      model: new Playlists.Models.Player(
        volume: volume,
        duration_mode: dur_mode
      )
    )

  soundManager.ontimeout ->
    notify 'Плеер завис, перезагрузите страницу! (F5)'
  
window.ajaxSetup = ->
  $.ajaxSetup
    cache: false
    #beforeSend: (jqXHR) ->
    #  jqXHR.setRequestHeader 'kookies', kookies

  $(document).ajaxError (e, jqxhr, settings, exception) ->
    # console.error arguments
    # console.error jqxhr.responseText
    data = JSON.parse jqxhr.responseText
    if jqxhr.status == 403
      if data.error == 'abuse'
        return notify 'Вы слишком часто обращаетесь к серверу,
          вы случайно не робот? Если да, то мы вас скоро забаним :-)', 'error', true
      notify "Запрещенное действие.  #{exception}"
    else if jqxhr.status == 401
      if data.error == 'auth fail'
        return notify "Вы почему-то не авторизованы. Обновите страницу. #{exception}"
      notify "Ошибка авторизации. #{exception}"
    else
      notify "Упс, эта функция сломалась. Уже чиним. (#{exception})"

window.searchSetup = ->
  $('#search_input').keydown (e) ->
    if e.which == 13 # Enter
      query = e.currentTarget.value
      return notify 'Запрос слишком короткий' and $('#search_input').val '' if query.length < 3
      $('#search_input').val ''
      # try search from playlist on client side
      if ps = App.playlists.where(url: query)
        return App.navigate query, true if ps.length
      if ps = App.playlists.where(name: query)
        return App.navigate ps[0].get('url'), true if ps.length
      App.navigate "/search/#{query}", true

window.playerSetup = ->

  $(".navbar").hover () ->
    $('#slider').show()
  , () ->
    return if App.player?.update == false
    $('#slider').hide()

  $('#slider').draggable(
    drag: (event, ui) ->
      App.player.update = false
      cur = ui.position.left
      all = $('#progress_line').width()
      percent = cur/all*100

      $('#play').width "#{percent}%"
    ,
    stop: (event, ui) -> 
      App.player.update = true
      cur = ui.position.left
      all = $('#progress_line').width()
      percent = cur/all*100

      App.player.setPosition percent
      setTimeout (-> $('#slider').hide()), 3000
    , axis: 'x'
  )

  $('#progress_line').click (e) ->
    App.player.update = true
    cur = e.offsetX
    all = $('#progress_line').width()
    percent = cur/all*100

    App.player.setPosition percent
    # setTimeout (-> $('#slider').hide()), 3000

window.lastfm = {}
lastfm.settings =
  _auth_url      : 'http://www.last.fm/api/auth'
  api_key        : 'e05ce4a3913e89f05cbed944d8a53851',
  api_secret     : 'dc37074d34defcf7a5f9b96192b26ae2'
  auth_url       :  -> "#{@_auth_url}/?api_key=#{@api_key}",
  get_auth_token : -> location.href = @auth_url()
  session_key    : if sk = localStorage.session_key then sk else null
  session_name   : if ln = localStorage.session_name then ln else null
  scrobbing_perc : .7

window.lastfmSetup = ->
  lastfm.api = new LastFM lastfm.settings.api_key, lastfm.settings.api_secret
  lastfm.api.session.key = localStorage.session_key || null
  lastfm.api.session.name = localStorage.session_name || null

window.clear_lastfm_session = ->
  delete lastfm.api.session.key
  delete lastfm.api.session.name 

  delete localStorage.session_key
  delete localStorage.session_name

window.userSetup = ->
  
  settigs_lastfm_enable = true

  if my_profile?
    my_profile.settings =
      lastfm:
        enable: settigs_lastfm_enable and localStorage.session_key?
      twitter:
        enable: false

window.pieconSetup = ->
  Piecon.setOptions
    color:      '#ff0084' # pie chart color i:
    background: '#bbb' # empty pie chart color
    shadow:     '#fff', # outer ring color
    fallback:   false # toggles displaying percentage in the title bar (possible values - true, false, 'force')

$ () ->
  if my_profile == -1
    show_ban_info() 
  
  unless debug
    window.l = console.log = console.warn = console.info = ->
    window.alert = window.notify

  window.App = new Playlists.Routers.AppRouter(
    playlists: my_profile['playlists']
  )
  
  bind_urls()

  soundManagerSetup()
  
  ajaxSetup()

  $('footer').tooltip
    selector: 'span[rel=tooltip]'
    placement: 'right'
    delay:
      show: 420, hide: 100

  searchSetup()

  userSetup()

  playerSetup()

  lastfmSetup()

  pieconSetup()

  if qbaka?
    u = my_profile.user
    qbaka.user = "#{u.id} #{u.last_name} #{u.first_name}"

  Backbone.history.start pushState: true

  # temporary monkey bug fix
  setInterval( (-> $('.tooltip').remove()), 60*1000)


