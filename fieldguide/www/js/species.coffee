parseList = (str) ->
  for val in str.toString().split(',')
    val = canonicalValue val
    continue if val.length is 0
    val

canonicalValue = (value) ->
  value.trim().toLowerCase().split(' ').join('_')

displayValue = (value) ->
  if value.length is 0
    ''
  else
    words = for word in value.split('_')
      word[0].toUpperCase() + word[1..]
    words.join(' ')

class Species
  constructor: (csvRow) ->
    @name = csvRow.name
    @description = csvRow.description
    @display_name = csvRow.display_name
    @pictures = parseList csvRow.pictures
    @features = {}
    reachedFeatures = false
    for k, v of csvRow
      k = canonicalValue k
      continue if k in ['name', 'display_name', 'description', 'pictures']
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
