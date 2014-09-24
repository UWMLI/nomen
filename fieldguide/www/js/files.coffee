'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

# Gives the callback an array of all subdirectories immediately inside the given
# directory reader.
getSubdirs = (dirReader, callback) ->
  subdirs = []
  getSome = ->
    dirReader.readEntries (results) ->
      if results.length is 0
        callback subdirs
      else
        newSubdirs =
          res for res in toArray results when res.isDirectory
        subdirs = subdirs.concat newSubdirs
        getSome()
  getSome()

# Gives the callback an array of all non-directory files found by recursively
# enumerating the directory reader.
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

window.getSubdirs = getSubdirs
window.getAllFiles = getAllFiles
