// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var Library, toArray;

  toArray = function(list) {
    return Array.prototype.slice.call(list || [], 0);
  };

  Library = (function() {
    function Library(datadir) {
      this.datadir = datadir;
      this.dir = "" + this.datadir + "/library";
    }

    Library.prototype.makeDir = function(callback) {
      return resolveLocalFileSystemURL(this.datadir, (function(_this) {
        return function(dir) {
          return dir.getDirectory('library', {
            create: true
          }, function() {
            return callback();
          });
        };
      })(this));
    };

    Library.prototype.deleteDir = function(callback) {
      return resolveLocalFileSystemURL(this.dir, (function(_this) {
        return function(dir) {
          return dir.removeRecursively(callback);
        };
      })(this), callback);
    };

    Library.prototype.deleteSet = function(id, callback) {
      return resolveLocalFileSystemURL("" + this.dir + "/" + id, (function(_this) {
        return function(dir) {
          return dir.removeRecursively(callback);
        };
      })(this), callback);
    };

    Library.prototype.makeSet = function(id, callback) {
      return this.deleteSet(id, (function(_this) {
        return function() {
          return resolveLocalFileSystemURL(_this.dir, function(dir) {
            return dir.getDirectory(id, {
              create: true
            }, function(dirEntry) {
              return callback(dirEntry);
            });
          });
        };
      })(this));
    };

    Library.prototype.scanLibrary = function(callback) {
      this.datasets = {};
      return resolveLocalFileSystemURL(this.dir, (function(_this) {
        return function(dirEntry) {
          var dirReader, readEntries, setsToAdd;
          dirReader = dirEntry.createReader();
          setsToAdd = [];
          readEntries = function() {
            if (setsToAdd.length === 0) {
              return dirReader.readEntries(function(results) {
                var res;
                if (results.length === 0) {
                  return callback();
                } else {
                  setsToAdd = (function() {
                    var _i, _len, _ref, _results;
                    _ref = toArray(results);
                    _results = [];
                    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                      res = _ref[_i];
                      if (res.isDirectory) {
                        _results.push(res);
                      }
                    }
                    return _results;
                  })();
                  return readEntries();
                }
              });
            } else {
              return _this.addLibrary(setsToAdd.pop(), readEntries);
            }
          };
          return readEntries();
        };
      })(this), (function(_this) {
        return function() {
          return callback();
        };
      })(this));
    };

    Library.prototype.addLibrary = function(dirEntry, callback) {
      var ds;
      ds = new Dataset(dirEntry.toURL());
      return ds.loadInfo((function(_this) {
        return function() {
          _this.datasets[ds.id] = ds;
          return callback();
        };
      })(this));
    };

    return Library;

  })();

  window.Library = Library;

}).call(this);
