'use strict'

parseList = (str) ->
  v for v in str.toString().split(',').map(canonicalValue) when v.length isnt 0

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
  # Create a Species given one row from the species.csv file as an object.
  constructor: (csvRow) ->
    @features = {}
    for k, v of csvRow
      k = canonicalValue k
      switch k
        when 'name'         then @name         = v
        when 'description'  then @description  = v
        when 'display_name' then @display_name = v
        else @features[k] = parseList v
    # Use name as display_name if display_name is undefined or ''
    @display_name = @name unless @display_name?.length

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
