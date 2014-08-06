toArray = (list) -> Array.prototype.slice.call(list || [], 0)

class Library
  constructor: (@dir) ->

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

  load: (callback) ->
    @loadInfo =>
      @loadImages =>
        @loadSpecies =>
          callback()

  loadInfo: (callback) ->
    $.getJSON "#{@dir}/info.json", (json) =>
      {@title, @id, @version} = json
      callback()

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

  addImage: (fileEntry) ->
    result = fileEntry.name.match /^(\w+)-(\w+)-(\w+)\.(\w+)$/
    if result?
      [whole, name, part, source, ext] = result
      @speciesImages[name] ?= []
      @speciesImages[name].push [part, fileEntry]
    else
      throw "Species image filename couldn't be parsed"

  loadSpecies: (callback) ->
    $.get "#{@dir}/species.csv", (str) =>
      @species = {}
      for csvRow in $.parse(str).results.rows
        spec = new Species csvRow
        @species[spec.name] = spec
      @listFeatures()
      callback()

  listFeatures: ->
    @features = {}
    for k, spec of @species
      for feature, values of spec.features
        @features[feature] ?= {}
        for value in values
          @features[feature][value] = true

  imagesForSpecies: (spec) ->
    @speciesImages[canonicalValue spec.name] ? []

window.Library = Library
window.DataSet = DataSet
