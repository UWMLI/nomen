'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

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

window.Library = Library
