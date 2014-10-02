// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var Remote;

  Remote = (function() {
    function Remote(datadir, url) {
      this.datadir = datadir;
      this.url = url;
      this.list = "" + this.datadir + "/remote.json";
    }

    Remote.prototype.getDataset = function(id) {
      var set, _i, _len, _ref;
      _ref = this.datasets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        set = _ref[_i];
        if (set.id === id) {
          return set;
        }
      }
      return null;
    };

    Remote.prototype.downloadList = function(callback, errback) {
      var transfer;
      transfer = new FileTransfer();
      transfer.download(this.url, this.list, (function(_this) {
        return function(entry) {
          $.getJSON(_this.list, function(json) {
            _this.datasets = json;
            callback();
          });
        };
      })(this), errback);
    };

    Remote.prototype.downloadDataset = function(id, lib, callback, errback) {
      var dataset, transfer, zipFile;
      dataset = this.getDataset(id);
      if (dataset == null) {
        errback("Couldn't find dataset: " + id);
        return;
      }
      zipFile = "" + this.datadir + "/" + id + ".zip";
      transfer = new FileTransfer();
      transfer.download(dataset.url, zipFile, (function(_this) {
        return function(zipEntry) {
          lib.makeSet(id, function(setEntry) {
            zip.unzip(zipFile, setEntry.toURL(), function(code) {
              zipEntry.remove(function() {
                if (code === 0) {
                  callback();
                } else {
                  errback("Unzip operation on " + zipFile + " returned " + code);
                }
              });
            });
          });
        };
      })(this), errback);
    };

    return Remote;

  })();

  window.Remote = Remote;

}).call(this);
