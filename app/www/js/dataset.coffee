'use strict'

class Dataset
  constructor: (@dir) ->

  # Load all the dataset information at once.
  load: (callback) ->>
    console.log 'Loading dataset info...'
    @loadInfo =>>
      console.log 'Loading species data...'
      @loadSpeciesData =>>
        console.log 'Loading feature images...'
        @loadFeatureImages =>>
          console.log 'Loading species images...'
          @loadSpeciesImages =>>
            console.log 'Done loading!'
            callback()

  # Load just the metadata JSON file.
  loadInfo: (callback) ->>
    $.getJSON "#{@dir}/info.json", (json) =>>
      {@title, @id, @version, @description, @author, @icon} = json
      if @icon
        @icon = resolveURI "#{@dir}/", @icon
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
      , =>>
        console.log "Tried to load from nonexistent folder: #{dir}"
        callback []

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
      feature = comparisonValue result[1]
      value = comparisonValue result[2]
      @featureImages[feature] ?= {}
      @featureImages[feature][value] = url
      return
    console.log "Couldn't parse feature image: #{url}"

  # Parse the species image filename to see which species and label it has.
  addSpeciesImage: (url) ->>
    url = decodeURI url
    return if url.match /\.DS_Store$/
    # Form: {species}{possibly label}.{ext}
    result = url.match ///
      (?: ^ | \/ )
      ([^\.\/]+)  # {species}{possibly label}
      (\. \w+)? $ # .{ext} (optional)
    ///
    if result?
      # Start trying to match initial sequences of the filename to a known
      # species (starting from the entire filename).
      img = comparisonValue result[1]
      for index in [img.length .. 0]
        name = img[..index]
        if @species[name]?
          label = img[index..]
          @speciesImages[name] ?= []
          @speciesImages[name].push [label, url]
          return
    console.log "Couldn't parse species image: #{url}"

  # Load the CSV file of species information.
  loadSpeciesData: (callback) ->>
    $.get "#{@dir}/species.csv", (str) =>>
      @species = {}
      for csvRow in $.parse(str).results.rows
        spec = new Species csvRow
        @species[comparisonValue spec.name] = spec
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

  featureDisplayName: (feature) ->
    for name, spec of @species
      for k, vs of spec.csvRow
        return k.split('_').join(' ') if feature is comparisonValue k

  valueDisplayName: (value) ->
    for name, spec of @species
      for k, vs of spec.csvRow
        for v in splitList vs
          return v.split('_').join(' ') if value is comparisonValue v

  # Get all the images (found via loadSpeciesImages) for a certain Species object.
  imagesForSpecies: (spec) ->
    imgs = @speciesImages[comparisonValue spec.name] ? []
    # We sort based on the label string, so that an image with no label
    # always becomes the first image.
    imgs.sort ([label1, url1], [label2, url2]) ->
      label1.localeCompare label2
    imgs

  # Gets the image (found via loadFeatureImages) for a feature/value pair,
  # or `undefined` if none is found.
  imageForFeature: (feature, value) ->
    (@featureImages[comparisonValue feature] ? {})[comparisonValue value]

# Works for Dataset objects as well as simple entries in a Remote.
datasetDisplay = (obj) ->
  "#{obj.title} v#{obj.version}"

window.Dataset = Dataset
window.datasetDisplay = datasetDisplay
