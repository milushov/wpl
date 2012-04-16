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


$(document).ajaxError (e, jqxhr, settings, exception) =>
  # console.error arguments
  alert "Упс. Кажется эта ссылка сейчас не работает. Уже чиним. (#{exception})"
  history.back()

window.too_late = 0
window.loading = (ready = false) ->
  fast_operation = 10
  loader = $('#head_loader')
  if ready
    console.warn "загрузилось", window.too_late
    # hide loader
    loader.fadeTo('fast', 0)
    window.too_late = 1
    42
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
      42
    , fast_operation
    42

