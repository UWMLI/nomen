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
    @loadSpecies =>
      @makeRows()
      @showLikely()
      @fillLikely()
      @resizeImage()
      $(window).resize => @resizeImage()
      console.log 'Loaded!'

  loadSpecies: (callback) ->
    $.get 'data/dataset.csv', (str) =>
      @species =
        new Species csvRow for csvRow in $.parse(str).results.rows
      @speciesHash = {}
      for spec in @species
        @speciesHash[spec.name] = spec
      @featureRows = for feature, values of allFeatures(@species)
        values = (v for v of values).sort()
        for value in values
          display: displayValue value
          image: "data/plantfeatures/#{feature}/#{feature}-#{value}.png"
          feature: feature
          value: value
      callback()

  makeRows: ->
    for row in @featureRows
      feature = row[0].feature
      appendTo $('#plants-content'), ->
        @div '.feature-row', ->
          @div '.feature-name', displayValue feature
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

  showLikely: ->
    $('#likely-button').html "#{@getLikely().length} Likely"

  getLikely: ->
    maxScore = Object.keys(@selected).length
    cutoff = maxScore * 0.9
    spec for spec in @species when spec.computeScore(@selected) >= cutoff

  fillLikely: ->
    $('#likely-content').html ''
    species = ([spec, spec.computeScore(@selected)] for spec in @species)
    species.sort (s1, s2) -> s2[1] - s1[1] # sorts by score descending
    for [spec, score] in species[0...10]
      appendTo $('#likely-content'), ->
        setFn = (i) -> "if (!event.wasImage) app.setSpecimen('#{spec.name}', #{i});"
        @a href: '#specimen', 'data-transition': 'slide', onclick: setFn(0), ->
          @div '.feature-row', ->
            @div '.feature-name', ->
              @text "#{spec.name} (#{score})"
            @div '.feature-boxes', ->
              if spec.pictures.length is 0
                @div '.feature-box', ->
                  @img '.feature-img', src: 'data/noimage.png'
                  @div '.feature-value', 'No Image'
              else
                for image, ix in spec.pictures
                  @div '.feature-box', onclick: "#{setFn(ix)} event.wasImage = true;", ->
                    @img '.feature-img', src: "data/plantphotos/#{image}.jpg"
                    result = image.match(/^(\w+)-(\w+)-(\w+)$/)
                    if result?
                      [__, scientific, part, place] = result
                      @div '.feature-value', displayValue part

  setSpecimen: (name, ix) ->
    spec = @speciesHash[name]
    @imgs =
      if spec.pictures.length is 0
        ['data/noimage.png']
      else
        "data/plantphotos/#{id}.jpg" for id in spec.pictures
    desc = spec.description
    $('#specimen-name').html(name)
    @imageIndex = ix
    @setImage()
    $('.specimen-text').html(desc)

  setImage: ->
    img = @imgs[@imageIndex]
    $('.specimen-img').css('background-image', "url(#{img})")
    $('.specimen-img-fake').prop('src', img)

  resizeImage: ->
    h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
    $('.specimen-img-box').css('height', "#{h - 100}px")

window.app = new App
