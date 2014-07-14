parseList = (str) ->
  for val in str.toString().split(',')
    val = val.trim().toLowerCase().split(' ').join('_')
    continue if val.length is 0
    val

canonicalValue = (value) ->
  value.trim().toLowerCase().split(' ').join('_')

displayValue = (value) ->
  words = for word in value.split('_')
    word[0].toUpperCase() + word[1..]
  words.join(' ')

class Species
  constructor: (csvRow) ->
    @name = csvRow.Scientific_name
    @description = csvRow.Description
    @pictures = parseList csvRow.Pictures
    @features = {}
    reachedFeatures = false
    for k, v of csvRow
      k = canonicalValue k
      reachedFeatures ||= k is 'flower_color'
      continue unless reachedFeatures
      continue if k in ['plant_height', 'petiole_present']
      continue if k in ['scientific_name', 'description', 'pictures']
      @features[k] = parseList v

  computeScore: (selected) ->
    score = 0
    for feature, values of selected
      overlap =
        v for v of values when v in @features[feature]
      score++ if overlap.length != 0
    score

allFeatures = (specs) ->
  hsh = {}
  for spec in specs
    for feature, values of spec.features
      hsh[feature] ?= {}
      for value in values
        hsh[feature][value] = true
  hsh

window.Species = Species
window.allFeatures = allFeatures
window.displayValue = displayValue
