// Generated by CoffeeScript 1.7.1
(function() {
  var Species, allFeatures, canonicalValue, displayValue, parseList,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  parseList = function(str) {
    var val, _i, _len, _ref, _results;
    _ref = str.toString().split(',');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      val = _ref[_i];
      val = canonicalValue(val);
      if (val.length === 0) {
        continue;
      }
      _results.push(val);
    }
    return _results;
  };

  canonicalValue = function(value) {
    return value.trim().toLowerCase().split(' ').join('_');
  };

  displayValue = function(value) {
    var word, words;
    if (value.length === 0) {
      return '';
    } else {
      words = (function() {
        var _i, _len, _ref, _results;
        _ref = value.split('_');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          word = _ref[_i];
          _results.push(word[0].toUpperCase() + word.slice(1));
        }
        return _results;
      })();
      return words.join(' ');
    }
  };

  Species = (function() {
    function Species(csvRow) {
      var k, reachedFeatures, v;
      this.name = csvRow.name;
      this.description = csvRow.description;
      this.display_name = csvRow.display_name;
      this.pictures = parseList(csvRow.pictures);
      this.features = {};
      reachedFeatures = false;
      for (k in csvRow) {
        v = csvRow[k];
        k = canonicalValue(k);
        if (k === 'name' || k === 'display_name' || k === 'description' || k === 'pictures') {
          continue;
        }
        this.features[k] = parseList(v);
      }
    }

    Species.prototype.computeScore = function(selected) {
      var feature, overlap, score, v, values;
      score = 0;
      for (feature in selected) {
        values = selected[feature];
        overlap = (function() {
          var _results;
          _results = [];
          for (v in values) {
            if (__indexOf.call(this.features[feature], v) >= 0) {
              _results.push(v);
            }
          }
          return _results;
        }).call(this);
        if (overlap.length !== 0) {
          score++;
        }
      }
      return score;
    };

    return Species;

  })();

  allFeatures = function(specs) {
    var feature, hsh, spec, value, values, _i, _j, _len, _len1, _ref;
    hsh = {};
    for (_i = 0, _len = specs.length; _i < _len; _i++) {
      spec = specs[_i];
      _ref = spec.features;
      for (feature in _ref) {
        values = _ref[feature];
        if (hsh[feature] == null) {
          hsh[feature] = {};
        }
        for (_j = 0, _len1 = values.length; _j < _len1; _j++) {
          value = values[_j];
          hsh[feature][value] = true;
        }
      }
    }
    return hsh;
  };

  window.Species = Species;

  window.allFeatures = allFeatures;

  window.displayValue = displayValue;

}).call(this);
