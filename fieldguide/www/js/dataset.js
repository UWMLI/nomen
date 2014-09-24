// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var Dataset, datasetDisplay, getAllFiles, toArray;

  toArray = function(list) {
    return Array.prototype.slice.call(list || [], 0);
  };

  getAllFiles = function(dirReader, callback) {
    var files, getSome, readers;
    files = [];
    readers = [];
    getSome = function() {
      return dirReader.readEntries(function(results) {
        var file, _i, _len, _ref;
        if (results.length === 0) {
          if (readers.length === 0) {
            return callback(files);
          } else {
            dirReader = readers.pop();
            return getSome();
          }
        } else {
          _ref = toArray(results);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            file = _ref[_i];
            if (file.isFile) {
              files.push(file);
            } else if (file.isDirectory) {
              readers.push(file.createReader());
            }
          }
          return getSome();
        }
      });
    };
    return getSome();
  };

  Dataset = (function() {
    function Dataset(dir) {
      this.dir = dir;
    }

    Dataset.prototype.load = function(callback) {
      return this.loadInfo((function(_this) {
        return function() {
          return _this.loadFeatureImages(function() {
            return _this.loadSpeciesImages(function() {
              return _this.loadSpeciesData(function() {
                return callback();
              });
            });
          });
        };
      })(this));
    };

    Dataset.prototype.loadInfo = function(callback) {
      return $.getJSON("" + this.dir + "/info.json", (function(_this) {
        return function(json) {
          _this.title = json.title, _this.id = json.id, _this.version = json.version;
          return callback();
        };
      })(this));
    };

    Dataset.prototype.loadDirectory = function(json, dir, callback) {
      return $.getJSON(json, (function(_this) {
        return function(urls) {
          var fixedURLs, url;
          fixedURLs = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = urls.length; _i < _len; _i++) {
              url = urls[_i];
              if (url.match(/^https?:\/\//) != null) {
                _results.push(url);
              } else {
                _results.push("" + dir + "/" + url);
              }
            }
            return _results;
          })();
          return callback(fixedURLs);
        };
      })(this)).fail((function(_this) {
        return function() {
          return resolveLocalFileSystemURL(dir, function(dirEntry) {
            return getAllFiles(dirEntry.createReader(), function(entries) {
              var entry, urls;
              urls = (function() {
                var _i, _len, _results;
                _results = [];
                for (_i = 0, _len = entries.length; _i < _len; _i++) {
                  entry = entries[_i];
                  _results.push(entry.toURL());
                }
                return _results;
              })();
              return callback(urls);
            });
          });
        };
      })(this));
    };

    Dataset.prototype.loadFeatureImages = function(callback) {
      this.featureImages = {};
      return this.loadDirectory("" + this.dir + "/features.json", "" + this.dir + "/features/", (function(_this) {
        return function(images) {
          var image, _i, _len;
          for (_i = 0, _len = images.length; _i < _len; _i++) {
            image = images[_i];
            _this.addFeatureImage(image);
          }
          return callback();
        };
      })(this));
    };

    Dataset.prototype.loadSpeciesImages = function(callback) {
      this.speciesImages = {};
      return this.loadDirectory("" + this.dir + "/species.json", "" + this.dir + "/species/", (function(_this) {
        return function(images) {
          var image, _i, _len;
          for (_i = 0, _len = images.length; _i < _len; _i++) {
            image = images[_i];
            _this.addSpeciesImage(image);
          }
          return callback();
        };
      })(this));
    };

    Dataset.prototype.addFeatureImage = function(url) {
      var ext, feature, result, sep, value, whole, _base;
      result = url.match(/(^|\/)(\w+)\/(\w+)\.(\w+)$/);
      if (result != null) {
        whole = result[0], sep = result[1], feature = result[2], value = result[3], ext = result[4];
        feature = canonicalValue(feature);
        value = canonicalValue(value);
        if ((_base = this.featureImages)[feature] == null) {
          _base[feature] = {};
        }
        this.featureImages[feature][value] = url;
        return;
      }
      return console.log("Couldn't parse feature image: " + url);
    };

    Dataset.prototype.addSpeciesImage = function(url) {
      var ext, label, name, result, sep, whole, _base, _base1;
      result = url.match(/(^|\/)(\w+)-([\w-]+)\.(\w+)$/);
      if (result != null) {
        whole = result[0], sep = result[1], name = result[2], label = result[3], ext = result[4];
        name = canonicalValue(name);
        label = canonicalValue(label);
        if ((_base = this.speciesImages)[name] == null) {
          _base[name] = [];
        }
        this.speciesImages[name].push([label, url]);
        return;
      }
      result = url.match(/(^|\/)(\w+)\.(\w+)$/);
      if (result != null) {
        whole = result[0], sep = result[1], name = result[2], ext = result[3];
        name = canonicalValue(name);
        if ((_base1 = this.speciesImages)[name] == null) {
          _base1[name] = [];
        }
        this.speciesImages[name].push(['', url]);
        return;
      }
      return console.log("Couldn't parse species image: " + url);
    };

    Dataset.prototype.loadSpeciesData = function(callback) {
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

    Dataset.prototype.listFeatures = function() {
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

    Dataset.prototype.imagesForSpecies = function(spec) {
      var _ref;
      return (_ref = this.speciesImages[canonicalValue(spec.name)]) != null ? _ref : [];
    };

    Dataset.prototype.imageForFeature = function(feature, value) {
      var _ref;
      return ((_ref = this.featureImages[canonicalValue(feature)]) != null ? _ref : {})[canonicalValue(value)];
    };

    return Dataset;

  })();

  datasetDisplay = function(obj) {
    return "" + obj.title + " v" + obj.version;
  };

  window.Dataset = Dataset;

  window.datasetDisplay = datasetDisplay;

}).call(this);
