###
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
###

appendTo = (element, muggexpr) ->
  element.append( CoffeeMugg.render(muggexpr, format: no) ).trigger('create')

class App
  initialize: ->
    $(document).ready =>
      @onDeviceReady()
    #document.addEventListener 'deviceready', @onDeviceReady, false

  onDeviceReady: ->
    FastClick.attach document.body
    @setBlur()
    $(document).scroll => @setBlur()
    $(document).bind('touchmove', (e) => @setBlur())
    @loadSpecies =>
      @loadFeatures =>
        @makeRows()
        @showLikely()
        @fillLikely()
        @addSwipe()
        console.log 'Loaded!'

  addSwipe: ->
    $('#specimen-content').on 'swipe', (event) =>
      start = event.swipestart.coords[0]
      end = event.swipestop.coords[0]
      if start < end
        @swipeRight()
      else
        @swipeLeft()

  ###
  scrollBlur: ->
    $(window).scroll (e) ->
      console.log($(window).scrollTop())
      $('.blur').css('opacity', $(window).scrollTop() / 150)
  ###

  loadSpecies: (callback) ->
    $.get 'data/dataset.csv', (str) =>
      @species = $.parse(str).results.rows
      @speciesHash = {}
      for spec in @species
        @speciesHash[spec.Scientific_name] = spec
      callback()

  loadFeatures: (callback) ->
    $.getJSON 'data/plantfeatures.json', (json) =>
      @featureRows =
        for feature, values of json
          for value in values
            display: value.split('_').join(' ')
            image: "data/plantfeatures/#{feature}/#{feature}-#{value}.png"
            feature: feature
            value: value
      callback()

  makeRows: ->
    for row in @featureRows
      feature = row[0].feature
      appendTo $('#plants-content'), ->
        @div '.feature-row', ->
          @div '.feature-name', feature.split('_').join(' ')
          @div '.feature-boxes', ->
            for {display, image, value} in row
              toggleFn = "app.toggleElement(this, '#{feature}', '#{value}');"
              @div '.feature-box', onclick: toggleFn, ->
                @img '.feature-img', src: image
                @div '.feature-value', display
    @selected = {}

  toggleElement: (element, feature, value) ->
    @selected[feature] ?= {}

    if @selected[feature][value]
      delete @selected[feature][value]
    else
      @selected[feature][value] = true

    if Object.keys(@selected[feature]).length is 0
      delete @selected[feature]

    value = $(element).find '.feature-value'
    if value.hasClass 'selected'
      value.removeClass 'selected'
    else
      value.addClass 'selected'

    @showLikely()
    @fillLikely()

  computeScore: (species) ->
    score = 0
    for feature, values of @selected
      selectedValues =
        v.toLowerCase() for v of values
      speciesValues =
        v.toLowerCase() for v in species[feature].toString().split(/\s*,\s*/)
      overlap =
        v for v in selectedValues when v in speciesValues
      score++ if overlap.length != 0
    score

  showLikely: ->
    $('#likely-button').html "#{@getLikely().length} Likely"

  getLikely: ->
    maxScore = Object.keys(@selected).length
    cutoff = maxScore * 0.9
    spec for spec in @species when @computeScore(spec) >= cutoff

  fillLikely: ->
    $('#likely-content').html ''
    species = ([spec, @computeScore spec] for spec in @species)
    species.sort (s1, s2) -> s2[1] - s1[1] # sorts by score descending
    for [spec, score] in species[0...10]
      appendTo $('#likely-content'), ->
        setFn = (i) -> "app.setSpecimen('#{spec.Scientific_name}', #{i})"
        @a href: '#specimen', 'data-transition': 'slide', ->
          @div '.feature-row', ->
            @div '.feature-name', onclick: setFn(0), ->
              @text "#{spec.Scientific_name} (#{score})"
            @div '.feature-boxes', ->
              if spec.Pictures.toString().match /^\s*$/
                @div '.feature-box', ->
                  @img '.feature-img', src: 'data/noimage.png'
                  @div '.feature-value', 'No Image'
              else
                for image, ix in spec.Pictures.toString().split(/\s*,\s*/)
                  @div '.feature-box', onclick: setFn(ix), ->
                    @img '.feature-img', src: "data/plantphotos/#{image}.jpg"
                    result = image.match(/^(\w+)-(\w+)-(\w+)$/)
                    if result?
                      [__, scientific, part, place] = result
                      @div '.feature-value', part.split('_').join(' ')

  setSpecimen: (name, ix) ->
    spec = @speciesHash[name]
    if spec.Pictures.toString().match /^\s*$/
      @imgs = ['data/noimage.png']
    else
      @imgs = for id in spec.Pictures.toString().split(/\s*,\s*/)
        "data/plantphotos/#{id}.jpg"
    desc = spec.Description
    $('#specimen-name').html(name)
    @imageIndex = ix
    @setImage()
    $('.specimen-text').html(desc)

  setImage: ->
    img = @imgs[@imageIndex]
    $('.specimen-img').css('background-image', "url(#{img})")
    $('.specimen-img-fake').prop('src', img)

  swipeLeft: ->
    if @imageIndex < @imgs.length - 1
      @imageIndex++
      @setImage()

  swipeRight: ->
    if @imageIndex > 0
      @imageIndex--
      @setImage()

  setBlur: ->
    scroll = $(document).scrollTop()
    windowHeight = $(window).height()
    maxScroll = $(document).height() - windowHeight
    if maxScroll > 50
      $('.blur').css('opacity', (scroll - 50) / (windowHeight * 0.5))
    else
      $('.blur').css('opacity', 0)

window.app = new App
