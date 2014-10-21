'use strict'

class Dataset
  constructor: (@dir) ->

  # Load all the dataset information at once.
  load: (callback) ->>
    @loadInfo =>>
      @loadFeatureImages =>>
        @loadSpeciesImages =>>
          @loadSpeciesData =>>
            callback()

  # Load just the metadata JSON file.
  loadInfo: (callback) ->>
    $.getJSON "#{@dir}/info.json", (json) =>>
      {@title, @id, @version} = json
      callback()

  # Loads a directory listing either from a JSON file or by recursive traversal.
  # The JSON file should be an array of paths; see getJSONList for details.
  loadDirectory: (json, dir, callback) ->>
    # First, try to load the JSON file.
    getJSONList json, callback
    # If that fails, then do the directory traversal.
    , =>>
      resolveLocalFileSystemURL dir, (dirEntry) =>>
        getAllFiles dirEntry.createReader(), (entries) =>>
          urls =
            entry.toURL() for entry in entries
          callback urls

  # Locate all images in the features images folder.
  loadFeatureImages: (callback) ->>
    @featureImages = {}
    @loadDirectory "#{@dir}/features.json", "#{@dir}/features/", (images) =>>
      @addFeatureImage image for image in images
      callback()

  # Locate all images in the species images folder.
  loadSpeciesImages: (callback) ->>
    @speciesImages = {}
    @loadDirectory "#{@dir}/species.json", "#{@dir}/species/", (images) =>>
      @addSpeciesImage image for image in images
      callback()

  # Parse the feature image filename to see which feature and value it is for.
  addFeatureImage: (url) ->>
    url = decodeURI url
    return if url.match /\.DS_Store$/
    # Form: {feature}/{value}.{ext}
    result = url.match ///
      (?: ^ | \/)
      ([\w\ \-]+) \/ # {feature}/
      ([\w\ \-]+)    # {value}
      \. \w+ $       # .{ext}
    ///
    if result?
      feature = canonicalValue result[1]
      value = canonicalValue result[2]
      @featureImages[feature] ?= {}
      @featureImages[feature][value] = url
      return
    console.log "Couldn't parse feature image: #{url}"

  # Parse the species image filename to see which species and label it has.
  addSpeciesImage: (url) ->>
    url = decodeURI url
    # General form: {species}-{label}.{ext}
    result = url.match ///
      (?: ^ | \/ )
      ([\w\ ]+) - # {species}-
      ([\w\ -]+)  # {label}
      \. \w+ $    # .{ext}
    ///
    if result?
      name = canonicalValue result[1]
      label = canonicalValue result[2]
      @speciesImages[name] ?= []
      @speciesImages[name].push [label, url]
      return
    # Simple form: {species}.{ext} (empty label)
    result = url.match ///
      (?: ^ | \/ )
      ([\w\ ]+) # {species}
      \. \w+ $  # .{ext}
    ///
    if result?
      name = canonicalValue result[1]
      @speciesImages[name] ?= []
      @speciesImages[name].push ['', url]
      return
    console.log "Couldn't parse species image: #{url}"

  # Load the CSV file of species information.
  loadSpeciesData: (callback) ->>
    $.get "#{@dir}/species.csv", (str) =>>
      @species = {}
      for csvRow in $.parse(str).results.rows
        spec = new Species csvRow
        @species[spec.name] = spec
      @listFeatures()
      callback()

  # Compute all features and values held by any species in the dataset.
  listFeatures: ->>
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
