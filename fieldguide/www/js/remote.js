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

    Remote.prototype.downloadList = function(callback) {
      var transfer;
      transfer = new FileTransfer();
      return transfer.download(this.url, this.list, (function(_this) {
        return function(entry) {
          return $.getJSON(_this.list, function(json) {
            _this.datasets = json;
            return callback();
          });
        };
      })(this));
    };

    Remote.prototype.downloadDataset = function(id, lib, callback) {
      var match, set, transfer, zipFile;
      match = (function() {
        var _i, _len, _ref, _results;
        _ref = this.datasets;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          set = _ref[_i];
          if (set.id === id) {
            _results.push(set);
          }
        }
        return _results;
      }).call(this);
      if (match[0] == null) {
        throw "Couldn't find dataset in remote list: " + id;
      }
      zipFile = "" + this.datadir + "/" + id + ".zip";
      transfer = new FileTransfer();
      return transfer.download(match[0].url, zipFile, (function(_this) {
        return function(zipEntry) {
          return lib.makeSet(id, function(setEntry) {
            return zip.unzip(zipFile, setEntry.toURL(), function(code) {
              return zipEntry.remove(function() {
                if (code !== 0) {
                  throw "Unzip operation on " + zipFile + " returned " + code;
                }
                return callback();
              });
            });
          });
        };
      })(this));
    };

    return Remote;

  })();

  window.Remote = Remote;

}).call(this);
