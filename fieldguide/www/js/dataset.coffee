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
              setsToAdd = toArray results
              readEntries()
        else
          @addLibrary setsToAdd.pop(), readEntries
      readEntries()

  addLibrary: (dirEntry, callback) ->
    ds = new DataSet dir.toURL()
    ds.loadInfo =>
      @datasets[ds.id] = ds
      callback()

class DataSet
  constructor: (@dir) ->

  load: (callback) ->
    @loadInfo =>
      @loadPics =>
        @loadSpecies callback

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
      @speciesImages[name] ?= {}
      @speciesImages[name][part] = fileEntry
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

window.Library = Library
window.DataSet = DataSet
