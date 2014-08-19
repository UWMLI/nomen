// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var DataSet, datasetDisplay, toArray;

  toArray = function(list) {
    return Array.prototype.slice.call(list || [], 0);
  };

  DataSet = (function() {
    function DataSet(dir) {
      this.dir = dir;
    }

    DataSet.prototype.load = function(callback) {
      return this.loadInfo((function(_this) {
        return function() {
          return _this.loadImages(function() {
            return _this.loadSpecies(function() {
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
          dirReader = dirEntry.createReader();
          readEntries = function() {
            return dirReader.readEntries(function(results) {
              var image, _i, _len, _ref;
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
      var ext, label, name, result, whole, _base;
      result = fileEntry.name.match(/^(\w+)-([\w-]+)\.(\w+)$/);
      if (result != null) {
        whole = result[0], name = result[1], label = result[2], ext = result[3];
        if ((_base = this.speciesImages)[name] == null) {
          _base[name] = [];
        }
        return this.speciesImages[name].push([label, fileEntry]);
      } else {
        return alert("Couldn't parse species image: " + fileEntry.name);
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

    DataSet.prototype.imagesForSpecies = function(spec) {
      var _ref;
      return (_ref = this.speciesImages[canonicalValue(spec.name)]) != null ? _ref : [];
    };

    return DataSet;

  })();

  datasetDisplay = function(obj) {
    return "" + obj.title + " v" + obj.version;
  };

  window.DataSet = DataSet;

  window.datasetDisplay = datasetDisplay;

}).call(this);
