// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  var Species, canonicalValue, displayValue, parseList,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  parseList = function(str) {
    var v, _i, _len, _ref, _results;
    _ref = str.toString().split(',').map(canonicalValue);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      v = _ref[_i];
      if (v.length !== 0) {
        _results.push(v);
      }
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
      var k, v, _ref;
      this.features = {};
      for (k in csvRow) {
        v = csvRow[k];
        k = canonicalValue(k);
        switch (k) {
          case 'name':
            this.name = v;
            break;
          case 'description':
            this.description = v;
            break;
          case 'display_name':
            this.display_name = v;
            break;
          default:
            this.features[k] = parseList(v);
        }
      }
      if (!((_ref = this.display_name) != null ? _ref.length : void 0)) {
        this.display_name = this.name;
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

  window.Species = Species;

  window.displayValue = displayValue;

  window.canonicalValue = canonicalValue;

}).call(this);
