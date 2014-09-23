'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

# Returns an array of all non-directory files recursively found in the
# directory reader's remaining results.
getAllFiles = (dirReader, callback) ->
  files = []
  readers = []
  getSome = ->
    dirReader.readEntries (results) ->
      if results.length is 0
        if readers.length is 0
          callback files
        else
          dirReader = readers.pop()
          getSome()
      else
        for file in toArray results
          if file.isFile
            files.push file
          else if file.isDirectory
            readers.push file.createReader()
        getSome()
  getSome()

class Dataset
  constructor: (@dir) ->

  # Load all the dataset information at once.
  load: (callback) ->
    @loadInfo =>
      @loadFeatureImages =>
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
    useImages = (images) =>
      for image in images
        @addFeatureImage image
      callback()
    # First, try to load a JSON file and use that as the file listing.
    $.getJSON "#{@dir}/features.json", useImages
    # Otherwise, actually do the directory traversal.
    .fail =>
      resolveLocalFileSystemURL "#{@dir}/features/", (dirEntry) =>
        getAllFiles dirEntry.createReader(), useImages

  # Locate all images in the species images folder.
  loadSpeciesImages: (callback) ->
    @speciesImages = {}
    useImages = (images) =>
      for image in images
        @addSpeciesImage image
      callback()
    # First, try to load a JSON file and use that as the file listing.
    $.getJSON "#{@dir}/species.json", useImages
    # Otherwise, actually do the directory traversal.
    .fail =>
      resolveLocalFileSystemURL "#{@dir}/species/", (dirEntry) =>
        getAllFiles dirEntry.createReader(), useImages

  # Parse the feature image filename to see which feature and value it is for.
  addFeatureImage: (fileEntry) ->
    # Form: .../features/{feature}/{value}.{ext}
    result = fileEntry.fullPath.match /features\/(\w+)\/(\w+)\.(\w+)$/
    if result?
      [whole, feature, value, ext] = result
      feature = canonicalValue feature
      value = canonicalValue value
      @featureImages[feature] ?= {}
      @featureImages[feature][value] = fileEntry
      return
    console.log "Couldn't parse feature image: #{fileEntry.fullPath}"

  # Parse the species image filename to see which species and label it has.
  addSpeciesImage: (fileEntry) ->
    # General form: {species}-{label}.{ext}
    result = fileEntry.name.match /^(\w+)-([\w-]+)\.(\w+)$/
    if result?
      [whole, name, label, ext] = result
      name = canonicalValue name
      label = canonicalValue label
      @speciesImages[name] ?= []
      @speciesImages[name].push [label, fileEntry]
      return
    # Simple form: {species}.{ext} (empty label)
    result = fileEntry.name.match /^(\w+)\.(\w+)$/
    if result?
      [whole, name, ext] = result
      name = canonicalValue name
      @speciesImages[name] ?= []
      @speciesImages[name].push ['', fileEntry]
      return
    console.log "Couldn't parse species image: #{fileEntry.name}"

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

  # Gets the image (found via loadFeatureImages) for a feature/value pair,
  # or `undefined` if none is found.
  imageForFeature: (feature, value) ->
    (@featureImages[canonicalValue feature] ? {})[canonicalValue value]

# Works for Dataset objects as well as simple entries in a Remote.
datasetDisplay = (obj) ->
  "#{obj.title} v#{obj.version}"

window.Dataset = Dataset
window.datasetDisplay = datasetDisplay
