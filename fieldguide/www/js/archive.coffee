'use strict'

class Archive
  constructor: (@json) ->

  # Get the list of datasets from the archive JSON.
  scanLibrary: (callback) ->>
    @datasets = {}
    processDirs = (urls) =>>
      if urls.length is 0
        callback()
      else
        @addLibrary resolveURI(@json, urls.pop()), => processDirs urls
    # Load the JSON to get the subdirectory listing.
    getJSONList @json, processDirs
    # If that fails, @datasets is already {} so just callback.
    , callback

  addLibrary: (url, callback) ->>
    ds = new Dataset url
    ds.loadInfo =>>
      @datasets[ds.id] = ds
      callback()

window.Archive = Archive
