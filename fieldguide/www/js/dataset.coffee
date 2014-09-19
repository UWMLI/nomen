'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

# Executes `action` for each entry left in the directory reader.
readAll = (dirReader, action) ->
  dirReader.readEntries (results) =>
    if results.length isnt 0
      action file for file in toArray results
      readAll dirReader, action

class Dataset
  constructor: (@dir) ->

  # Load all the dataset information at once.
  load: (callback) ->
    @loadInfo =>
      # TODO: loadFeatureImages
      @loadSpeciesImages =>
        @loadSpeciesData =>
          callback()

  # Load just the metadata JSON file.
  loadInfo: (callback) ->
    $.getJSON "#{@dir}/info.json", (json) =>
      {@title, @id, @version} = json
      callback()

  # Locate all images in the features images folder.
  loadFeatureImages: (callback) ->
    @featureImages = {}
    resolveLocalFileSystemURL "#{@dir}/features/", (dirEntry) =>
      readAll dirEntry.createReader(), (fileEntry) =>
        if fileEntry.isDirectory
          readAll fileEntry.createReader(), (image) =>
            @addFeatureImage image
      callback()

  # Locate all images in the species images folder.
  loadSpeciesImages: (callback) ->
    @speciesImages = {}
    resolveLocalFileSystemURL "#{@dir}/species/", (dirEntry) =>
      readAll dirEntry.createReader(), (image) =>
        @addSpeciesImage image
      callback()

  # Parse the feature image filename to see which feature and value it is for.
  addFeatureImage: (fileEntry) ->
    # TODO

  # Parse the species image filename to see which species and label it has.
  addSpeciesImage: (fileEntry) ->
    # General form: species-label.ext
    result = fileEntry.name.match /^(\w+)-([\w-]+)\.(\w+)$/
    if result?
      [whole, name, label, ext] = result
      name = canonicalValue name
      label = canonicalValue label
      @speciesImages[name] ?= []
      @speciesImages[name].push [label, fileEntry]
      return
    # Simple form: species.ext (empty label)
    result = fileEntry.name.match /^(\w+)\.(\w+)$/
    if result?
      [whole, name, ext] = result
      name = canonicalValue name
      @speciesImages[name] ?= []
      @speciesImages[name].push ['', fileEntry]
      return
    alert "Couldn't parse species image: #{fileEntry.name}"

  # Load the CSV file of species information.
  loadSpeciesData: (callback) ->
    $.get "#{@dir}/species.csv", (str) =>
      @species = {}
      for csvRow in $.parse(str).results.rows
        spec = new Species csvRow
        @species[spec.name] = spec
      @listFeatures()
      callback()

  # Compute all features and values held by any species in the dataset.
  listFeatures: ->
    @features = {}
    for k, spec of @species
      for feature, values of spec.features
        @features[feature] ?= {}
        for value in values
          @features[feature][value] = true

  # Get all the images (found via loadSpeciesImages) for a certain Species object.
  imagesForSpecies: (spec) ->
    @speciesImages[canonicalValue spec.name] ? []

# Works for Dataset objects as well as simple entries in a Remote.
datasetDisplay = (obj) ->
  "#{obj.title} v#{obj.version}"

window.Dataset = Dataset
window.datasetDisplay = datasetDisplay
