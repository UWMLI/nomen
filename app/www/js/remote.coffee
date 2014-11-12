'use strict'

class Remote
  constructor: (@datadir, @url) ->
    @list = "#{@datadir}/remote.json"

  getDataset: (id) ->
    return set for set in @datasets when set.id is id
    null

  downloadList: (callback, errback) ->>
    # TODO: this file gets cached. How to force redownload?
    # Tried https://github.com/moderna/cordova-plugin-cache with no luck.
    # https://github.com/apache/cordova-plugin-file-transfer/blob/master/doc/index.md
    # gives no indication of a "disable caching" feature.
    transfer = new FileTransfer()
    transfer.download @url, @list, (entry) =>>
      $.getJSON @list, (json) =>>
        @datasets = json
        for set in @datasets
          if set.icon?
            set.icon = resolveURI @url, set.icon
        callback()
    , errback

  downloadDataset: (id, lib, callback, errback) ->>
    dataset = @getDataset id
    unless dataset?
      errback "Couldn't find dataset: #{id}"
      return
    zipFile = "#{@datadir}/#{id}.zip"
    # TODO: potentially same caching issue as downloadList above?
    transfer = new FileTransfer()
    absoluteUrl = resolveURI @url, dataset.url
    transfer.download absoluteUrl, zipFile, (zipEntry) =>>
      lib.makeSet id, (setEntry) =>>
        zip.unzip zipFile, setEntry.toURL(), (code) =>>
          zipEntry.remove =>>
            if code is 0
              callback()
            else
              errback "Unzip operation on #{zipFile} returned #{code}"
    , errback

window.Remote = Remote
