'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

class Library
  constructor: (@datadir) ->
    @dir = "#{@datadir}/library"

  makeDir: (callback) ->
    resolveLocalFileSystemURL @datadir, (dir) =>
      dir.getDirectory 'library', {create: yes}, =>
        callback()

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
