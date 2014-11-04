'use strict'

toArray = (list) -> Array.prototype.slice.call(list || [], 0)

resolveURI = (base, url) ->
  if url.match /^[A-Za-z]+:\/\//
    url
  else if base.match /\/$/
    "#{base}#{url}"
  else if '/' in base
    "#{base[0 .. base.lastIndexOf('/')]}#{url}"
  else
    url

# Reads a JSON file containing an array of paths. The paths can be:
# * relative to the folder containing the JSON file
# * absolute, starting with "http://" or "https://"
getJSONList = (json, success, failure) ->>
  # First, get the dir of the json file to make relative paths absolute.
  slashIndex = json.lastIndexOf '/'
  dir =
    if slashIndex is -1
      ''
    else
      json[0..slashIndex]
  # Then, try to read the JSON file.
  $.getJSON json, (urls) ->>
    fixedURLs = for url in urls
      if url.match(/^https?:\/\//)?
        url
      else
        "#{dir}#{url}"
    success fixedURLs
  .fail failure

# Gives the callback an array of all subdirectories immediately inside the given
# directory reader.
getSubdirs = (dirReader, callback) ->>
  subdirs = []
  getSome = ->>
    dirReader.readEntries (results) ->>
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
getAllFiles = (dirReader, callback) ->>
  files = []
  readers = []
  getSome = ->>
    dirReader.readEntries (results) ->>
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

window.resolveURI = resolveURI
window.getJSONList = getJSONList
window.getSubdirs = getSubdirs
window.getAllFiles = getAllFiles
