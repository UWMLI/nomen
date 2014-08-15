'use strict'

class Remote
  constructor: (@datadir, @url) ->
    @list = "#{@datadir}/remote.json"
    @zipFile = "#{@datadir}/temp.zip"

  downloadList: (callback) ->
    transfer = new FileTransfer()
    transfer.download @url, @list, (entry) =>
      $.getJSON @list, (json) =>
        @datasets = json
        callback()

  downloadDataset: (id, lib, callback) ->
    match =
      set for set in @datasets when set.id is id
    throw "Couldn't find dataset in remote list: #{id}" unless match[0]?
    transfer = new FileTransfer()
    transfer.download match[0].url, @zipFile, (zipEntry) =>
      lib.makeSet id, (setEntry) =>
        zip.unzip @zipFile, setEntry.toURL(), (code) =>
          zipEntry.remove =>
            unless code is 0
              throw "Unzip operation on #{@zipFile} returned #{code}"
            callback()

window.Remote = Remote
