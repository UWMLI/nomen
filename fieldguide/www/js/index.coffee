###
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
###

class App
  initialize: ->
    @onDeviceReady()
    document.addEventListener 'deviceready', @onDeviceReady, false

  onDeviceReady: ->
    FastClick.attach document.body
    @loadSpecies =>
      @loadFeatures =>
        @makeRows()
        @showLikely()
        @fillLikely()
        console.log 'Loaded!'

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
    container = $('#plants-content')
    for row in @featureRows
      feature = row[0].feature
      htmlRow = $('<div />', class: 'feature-row')
      htmlRow.append("<div class='feature-name'>#{feature.split('_').join(' ')}</div>").trigger("create")
      for {display, image, value} in row
        htmlBox = $('<div />', {
          class: 'feature-box'
          onclick: "app.toggleElement(this, #{JSON.stringify feature}, #{JSON.stringify value});"
        })
        htmlBox.append("<div class='feature-value'>#{display}</div>").trigger("create")
        htmlBox.append($('<img />', class: 'feature-img', src: image)).trigger("create")
        htmlRow.append(htmlBox).trigger("create")
      container.append(htmlRow).trigger("create")
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
    container = $('#likely-content')
    for [spec, score] in species[0...10]
      htmlRow = $('<div />', class: 'feature-row')
      htmlRow.append("<div class='feature-name'>#{spec.Scientific_name} (#{score})</div>").trigger("create")
      if spec.Pictures.toString().match /^\s*$/
        htmlBox = $('<div class="feature-box" />')
        htmlBox.append("<div class='feature-value'>No Image</div>").trigger("create")
        htmlBox.append($('<img />', class: 'feature-img', src: 'data/noimage.png')).trigger("create")
        htmlRow.append(htmlBox).trigger("create")
      else
        for image in spec.Pictures.toString().split(/\s*,\s*/)
          img = "data/plantphotos/#{image}.jpg"
          htmlBox = $('<div class="feature-box" />')
          result = image.match(/^([A-Za-z0-9_]+)-([A-Za-z0-9_]+)-([A-Za-z0-9_]+)$/)
          if result?
            [__, scientific, part, place] = result
            part = part.split('_').join(' ')
            htmlBox.append("<div class='feature-value'>#{part}</div>").trigger("create")
          htmlBox.append($('<img />', class: 'feature-img', src: img)).trigger("create")
          htmlRow.append(htmlBox).trigger("create")
      setFn = "app.setSpecimen(#{JSON.stringify spec.Scientific_name})"
      htmlLink = $("<a href=\"#specimen\" data-transition=\"slide\" onclick='#{setFn}' />")
      htmlLink.append(htmlRow).trigger("create")
      container.append(htmlLink).trigger("create")

  setSpecimen: (name) ->
    spec = @speciesHash[name]
    if spec.Pictures.toString().match /^\s*$/
      img = 'data/noimage.png'
    else
      id = spec.Pictures.toString().split(/\s*,\s*/)[0]
      img = "data/plantphotos/#{id}.jpg"
    desc = spec.Description
    $('#specimen-name').html(name)
    $('.specimen-img').prop('src', img)
    $('.specimen-img-fake').prop('src', img)
    $('.specimen-text').html(desc)

window.app = new App
