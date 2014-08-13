'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

class Library
  constructor: (@dir) ->

  # Scan the library folder for datasets.
  scanLibrary: (callback) ->
    @datasets = {}
    resolveLocalFileSystemURL @dir, (dirEntry) =>
      dirReader = dirEntry.createReader()
      setsToAdd = []
      readEntries = =>
        if setsToAdd.length is 0
          dirReader.readEntries (results) =>
            if results.length is 0
              callback()
            else
              setsToAdd =
                res for res in toArray results when res.isDirectory
              readEntries()
        else
          @addLibrary setsToAdd.pop(), readEntries
      readEntries()
    , => callback()
    # on error (lib dir doesn't exist), we just continue.
    # @datasets is {} which is correct

  addLibrary: (dirEntry, callback) ->
    ds = new DataSet dirEntry.toURL()
    ds.loadInfo =>
      @datasets[ds.id] = ds
      callback()

class DataSet
  constructor: (@dir) ->

  # Load all the dataset information at once.
  load: (callback) ->
    @loadInfo =>
      @loadImages =>
        @loadSpecies =>
          callback()

  # Load just the metadata JSON file.
  loadInfo: (callback) ->
    $.getJSON "#{@dir}/info.json", (json) =>
      {@title, @id, @version} = json
      callback()

  # Locate all images in the species images folder.
  loadImages: (callback) ->
    @speciesImages = {}
    resolveLocalFileSystemURL "#{@dir}/species/", (dirEntry) =>
      dirReader = dirEntry.createReader()
      readEntries = =>
        dirReader.readEntries (results) =>
          if results.length is 0
            callback()
          else
            @addImage image for image in toArray results
            readEntries()
      readEntries()

  # Parse the species image filename to see which species and label it has.
  addImage: (fileEntry) ->
    result = fileEntry.name.match /^(\w+)-([\w-]+)\.(\w+)$/
    if result?
      [whole, name, label, ext] = result
      @speciesImages[name] ?= []
      @speciesImages[name].push [label, fileEntry]
    else
      throw "Species image filename couldn't be parsed"

  # Load the CSV file of species information.
  loadSpecies: (callback) ->
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

  # Get all the images (found via loadImages) for a certain Species object.
  imagesForSpecies: (spec) ->
    @speciesImages[canonicalValue spec.name] ? []

window.Library = Library
window.DataSet = DataSet
