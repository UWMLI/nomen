// Generated by CoffeeScript 1.7.1
(function() {
  var DataSet, Library, toArray;

  toArray = function(list) {
    return Array.prototype.slice.call(list || [], 0);
  };

  Library = (function() {
    function Library(dir) {
      this.dir = dir;
    }

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
      })(this));
    };

    Library.prototype.addLibrary = function(dirEntry, callback) {
      var ds;
      ds = new DataSet(dirEntry.toURL());
      return ds.loadInfo((function(_this) {
        return function() {
          _this.datasets[ds.id] = ds;
          return callback();
        };
      })(this));
    };

    return Library;

  })();

  DataSet = (function() {
    function DataSet(dir) {
      this.dir = dir;
    }

    DataSet.prototype.load = function(callback) {
      return this.loadInfo((function(_this) {
        return function() {
          return _this.loadImages(function() {
            alert('loaded images');
            return _this.loadSpecies(function() {
              alert('loaded species');
              return callback();
            });
          });
        };
      })(this));
    };

    DataSet.prototype.loadInfo = function(callback) {
      return $.getJSON("" + this.dir + "/info.json", (function(_this) {
        return function(json) {
          _this.title = json.title, _this.id = json.id, _this.version = json.version;
          return callback();
        };
      })(this));
    };

    DataSet.prototype.loadImages = function(callback) {
      this.speciesImages = {};
      return resolveLocalFileSystemURL("" + this.dir + "/species/", (function(_this) {
        return function(dirEntry) {
          var dirReader, readEntries;
          alert('resolved');
          dirReader = dirEntry.createReader();
          readEntries = function() {
            alert('reading');
            return dirReader.readEntries(function(results) {
              var image, _i, _len, _ref;
              alert(results.length);
              if (results.length === 0) {
                return callback();
              } else {
                _ref = toArray(results);
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  image = _ref[_i];
                  _this.addImage(image);
                }
                return readEntries();
              }
            });
          };
          return readEntries();
        };
      })(this));
    };

    DataSet.prototype.addImage = function(fileEntry) {
      var ext, name, part, result, source, whole, _base;
      alert(fileEntry.name);
      result = fileEntry.name.match(/^(\w+)-(\w+)-(\w+)\.(\w+)$/);
      if (result != null) {
        whole = result[0], name = result[1], part = result[2], source = result[3], ext = result[4];
        if ((_base = this.speciesImages)[name] == null) {
          _base[name] = {};
        }
        return this.speciesImages[name][part] = fileEntry;
      } else {
        throw "Species image filename couldn't be parsed";
      }
    };

    DataSet.prototype.loadSpecies = function(callback) {
      return $.get("" + this.dir + "/species.csv", (function(_this) {
        return function(str) {
          var csvRow, spec, _i, _len, _ref;
          _this.species = {};
          _ref = $.parse(str).results.rows;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            csvRow = _ref[_i];
            spec = new Species(csvRow);
            _this.species[spec.name] = spec;
          }
          _this.listFeatures();
          return callback();
        };
      })(this));
    };

    DataSet.prototype.listFeatures = function() {
      var feature, k, spec, value, values, _ref, _results;
      this.features = {};
      _ref = this.species;
      _results = [];
      for (k in _ref) {
        spec = _ref[k];
        _results.push((function() {
          var _base, _ref1, _results1;
          _ref1 = spec.features;
          _results1 = [];
          for (feature in _ref1) {
            values = _ref1[feature];
            if ((_base = this.features)[feature] == null) {
              _base[feature] = {};
            }
            _results1.push((function() {
              var _i, _len, _results2;
              _results2 = [];
              for (_i = 0, _len = values.length; _i < _len; _i++) {
                value = values[_i];
                _results2.push(this.features[feature][value] = true);
              }
              return _results2;
            }).call(this));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return DataSet;

  })();

  window.Library = Library;

  window.DataSet = DataSet;

}).call(this);
