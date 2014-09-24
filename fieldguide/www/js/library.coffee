'use strict'

class Library
  constructor: (@datadir) ->
    @dir = "#{@datadir}/library"

  # Ensures that the library directory exists.
  makeDir: (callback) ->
    resolveLocalFileSystemURL @datadir, (dir) =>
      dir.getDirectory 'library', {create: yes}, =>
        callback()

  # Recursively deletes the whole library directory.
  deleteDir: (callback) ->
    resolveLocalFileSystemURL @dir, (dir) =>
      dir.removeRecursively callback
    , callback # if the dir doesn't exist, no problem

  # Recursively deletes a directory for a certain dataset.
  deleteSet: (id, callback) ->
    resolveLocalFileSystemURL "#{@dir}/#{id}", (dir) =>
      dir.removeRecursively callback
    , callback # if the dir doesn't exist, no problem

  # Makes an empty directory for a dataset to be downloaded into.
  makeSet: (id, callback) ->
    @deleteSet id, =>
      resolveLocalFileSystemURL @dir, (dir) =>
        dir.getDirectory id, {create: yes}, (dirEntry) =>
          callback dirEntry

  # Scan the library folder for datasets.
  scanLibrary: (callback) ->
    @datasets = {}
    resolveLocalFileSystemURL @dir, (dirEntry) =>
      dirReader = dirEntry.createReader()
      getSubdirs dirEntry.createReader(), (dirs) =>
        processDirs = =>
          if dirs.length is 0
            callback()
          else
            @addLibrary dirs.pop(), processDirs
        processDirs()
    , => callback()
    # on error (lib dir doesn't exist), we just continue.
    # @datasets is {} which is correct

  addLibrary: (dirEntry, callback) ->
    ds = new Dataset dirEntry.toURL()
    ds.loadInfo =>
      @datasets[ds.id] = ds
      callback()

window.Library = Library
