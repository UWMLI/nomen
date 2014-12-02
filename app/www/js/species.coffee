'use strict'

comparisonValue = (value) ->
  value.toLowerCase().replace(/[^a-z0-9]/g, '')

splitList = (value) ->
  v for v in value.toString().split(',').map((x) -> x.trim()) when v.length isnt 0

class Species
  # Create a Species given one row from the species.csv file as an object.
  constructor: (csvRow) ->
    @features = {}
    for k, v of csvRow
      k = comparisonValue k
      switch k
        when 'name'        then @name         = v.trim()
        when 'description' then @description  = v.trim()
        when 'displayname' then @display_name = v.trim()
        else @features[k] = splitList v
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
window.comparisonValue = comparisonValue
