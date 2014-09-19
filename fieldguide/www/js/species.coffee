'use strict'

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

indexCanon = (obj, key) ->
  for okey of obj
    if (canonicalValue okey) is key
      return obj[okey]
  return

class Species
  # Create a Species given one row from the species.csv file as an object.
  constructor: (csvRow) ->
    @name = indexCanon csvRow, 'name'
    @description = indexCanon csvRow, 'description'
    @display_name = (indexCanon csvRow, 'display_name') ? @name
    @features = {}
    reachedFeatures = false
    for k, v of csvRow
      k = canonicalValue k
      continue if k in ['name', 'display_name', 'description']
      @features[k] = parseList v

  # If `selected` is an object from features to arrays of values,
  # compute how many of them match the features of this species.
  computeScore: (selected) ->
    score = 0
    for feature, values of selected
      overlap =
        v for v of values when v in @features[feature]
      score++ if overlap.length != 0
    score

window.Species = Species
window.displayValue = displayValue
window.canonicalValue = canonicalValue
