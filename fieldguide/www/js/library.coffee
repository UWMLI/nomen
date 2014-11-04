'use strict'

class Library
  constructor: (@datadir) ->
    @dir = "#{@datadir}/library"
    @json = "#{@datadir}/library.json"

  # Ensures that the library directory exists.
  makeDir: (callback) ->>
    resolveLocalFileSystemURL @datadir, (dir) =>>
      dir.getDirectory 'library', {create: yes}, =>>
        callback()

  # Recursively deletes the whole library directory.
  deleteDir: (callback) ->>
    resolveLocalFileSystemURL @dir, (dir) =>>
      dir.removeRecursively callback
    , callback # if the dir doesn't exist, no problem

  # Recursively deletes a directory for a certain dataset.
  deleteSet: (id, callback) ->>
    resolveLocalFileSystemURL "#{@dir}/#{id}", (dir) =>>
      dir.removeRecursively callback
    , callback # if the dir doesn't exist, no problem

  # Makes an empty directory for a dataset to be downloaded into.
  makeSet: (id, callback) ->>
    @deleteSet id, =>>
      resolveLocalFileSystemURL @dir, (dir) =>>
        dir.getDirectory id, {create: yes}, (dirEntry) =>>
          callback dirEntry

  # Scan the library folder for datasets.
  scanLibrary: (callback) ->>
    @datasets = {}
    processDirs = (urls) =>>
      if urls.length is 0
        callback()
      else
        @addLibrary resolveURI(@json, urls.pop()), => processDirs urls
    # First, try loading library.json to get the subdirectory listing.
    getJSONList @json, processDirs
    # If that fails, then actually traverse the directories.
    , =>>
      resolveLocalFileSystemURL @dir, (dirEntry) =>>
        dirReader = dirEntry.createReader()
        getSubdirs dirEntry.createReader(), (dirs) =>>
          processDirs(dir.toURL() for dir in dirs)
      # If the dir doesn't exist, there are no entries,
      # and @datasets is already {} so we just callback.
      , callback

  addLibrary: (url, callback) ->>
    ds = new Dataset url
    ds.loadInfo =>>
      @datasets[ds.id] = ds
      callback()

window.Library = Library
