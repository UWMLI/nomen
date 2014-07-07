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

  loadSpecies: (callback) ->
    $.get 'data/dataset.csv', (str) =>
      @species = $.parse(str).results.rows
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
      htmlRow.append $("<div class='feature-name'>#{feature.split('_').join(' ')}</div>")
      for {display, image, value} in row
        htmlBox = $('<div />', {
          class: 'feature-box'
          onclick: "app.toggleElement(#{JSON.stringify feature}, #{JSON.stringify value});"
        })
        htmlBox.append $("<div class='feature-value'>#{display}</div>")
        htmlBox.append $('<img />', class: 'feature-img', src: image)
        htmlRow.append htmlBox
      container.append htmlRow
    @selected = {}

  toggleElement: (feature, value) ->
    @selected[feature] ?= {}

    if @selected[feature][value]
      delete @selected[feature][value]
    else
      @selected[feature][value] = true

    if Object.keys(@selected[feature]).length is 0
      delete @selected[feature]

    @showLikely()
    @fillLikely()

  computeScore: (species) ->
    score = 0
    for feature, values of @selected
      selectedValues =
        v.toLowerCase().trim() for v of values
      speciesValues =
        v.toLowerCase().trim() for v in species[feature].toString().split(',')
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
    for [spec, score] in species
      entry = $("<h2>#{spec.Scientific_name} (#{score})</h2>")
      $('#likely-content').append entry

window.app = new App
