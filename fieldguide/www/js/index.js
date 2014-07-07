
/*
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
*/


(function() {
  var App,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  App = (function() {

    function App() {}

    App.prototype.initialize = function() {
      this.onDeviceReady();
      return document.addEventListener('deviceready', this.onDeviceReady, false);
    };

    App.prototype.onDeviceReady = function() {
      var _this = this;
      FastClick.attach(document.body);
      return this.loadSpecies(function() {
        return _this.loadFeatures(function() {
          _this.makeRows();
          _this.showLikely();
          _this.fillLikely();
          return console.log('Loaded!');
        });
      });
    };

    App.prototype.loadSpecies = function(callback) {
      var _this = this;
      return $.get('data/dataset.csv', function(str) {
        _this.species = $.parse(str).results.rows;
        return callback();
      });
    };

    App.prototype.loadFeatures = function(callback) {
      var _this = this;
      return $.getJSON('data/plantfeatures.json', function(json) {
        var feature, value, values;
        _this.featureRows = (function() {
          var _results;
          _results = [];
          for (feature in json) {
            values = json[feature];
            _results.push((function() {
              var _i, _len, _results1;
              _results1 = [];
              for (_i = 0, _len = values.length; _i < _len; _i++) {
                value = values[_i];
                _results1.push({
                  display: value.split('_').join(' '),
                  image: "data/plantfeatures/" + feature + "/" + feature + "-" + value + ".png",
                  feature: feature,
                  value: value
                });
              }
              return _results1;
            })());
          }
          return _results;
        })();
        return callback();
      });
    };

    App.prototype.makeRows = function() {
      var container, display, feature, htmlBox, htmlRow, image, row, value, _i, _j, _len, _len1, _ref, _ref1;
      container = $('#plants-content');
      _ref = this.featureRows;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        feature = row[0].feature;
        htmlRow = $('<div />', {
          "class": 'feature-row'
        });
        htmlRow.append($("<div class='feature-name'>" + (feature.split('_').join(' ')) + "</div>"));
        for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
          _ref1 = row[_j], display = _ref1.display, image = _ref1.image, value = _ref1.value;
          htmlBox = $('<div />', {
            "class": 'feature-box',
            onclick: "app.toggleElement(this, " + (JSON.stringify(feature)) + ", " + (JSON.stringify(value)) + ");"
          });
          htmlBox.append($("<div class='feature-value'>" + display + "</div>"));
          htmlBox.append($('<img />', {
            "class": 'feature-img',
            src: image
          }));
          htmlRow.append(htmlBox);
        }
        container.append(htmlRow);
      }
      return this.selected = {};
    };

    App.prototype.toggleElement = function(element, feature, value) {
      var _base;
      if ((_base = this.selected)[feature] == null) {
        _base[feature] = {};
      }
      if (this.selected[feature][value]) {
        delete this.selected[feature][value];
      } else {
        this.selected[feature][value] = true;
      }
      if (Object.keys(this.selected[feature]).length === 0) {
        delete this.selected[feature];
      }
      value = $(element).find('.feature-value');
      if (value.hasClass('selected')) {
        value.removeClass('selected');
      } else {
        value.addClass('selected');
      }
      this.showLikely();
      return this.fillLikely();
    };

    App.prototype.computeScore = function(species) {
      var feature, overlap, score, selectedValues, speciesValues, v, values, _ref;
      score = 0;
      _ref = this.selected;
      for (feature in _ref) {
        values = _ref[feature];
        selectedValues = (function() {
          var _results;
          _results = [];
          for (v in values) {
            _results.push(v.toLowerCase().trim());
          }
          return _results;
        })();
        speciesValues = (function() {
          var _i, _len, _ref1, _results;
          _ref1 = species[feature].toString().split(',');
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            v = _ref1[_i];
            _results.push(v.toLowerCase().trim());
          }
          return _results;
        })();
        overlap = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = selectedValues.length; _i < _len; _i++) {
            v = selectedValues[_i];
            if (__indexOf.call(speciesValues, v) >= 0) {
              _results.push(v);
            }
          }
          return _results;
        })();
        if (overlap.length !== 0) {
          score++;
        }
      }
      return score;
    };

    App.prototype.showLikely = function() {
      return $('#likely-button').html("" + (this.getLikely().length) + " Likely");
    };

    App.prototype.getLikely = function() {
      var cutoff, maxScore, spec, _i, _len, _ref, _results;
      maxScore = Object.keys(this.selected).length;
      cutoff = maxScore * 0.9;
      _ref = this.species;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        spec = _ref[_i];
        if (this.computeScore(spec) >= cutoff) {
          _results.push(spec);
        }
      }
      return _results;
    };

    App.prototype.fillLikely = function() {
      var entry, score, spec, species, _i, _len, _ref, _results;
      $('#likely-content').html('');
      species = (function() {
        var _i, _len, _ref, _results;
        _ref = this.species;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          spec = _ref[_i];
          _results.push([spec, this.computeScore(spec)]);
        }
        return _results;
      }).call(this);
      species.sort(function(s1, s2) {
        return s2[1] - s1[1];
      });
      _results = [];
      for (_i = 0, _len = species.length; _i < _len; _i++) {
        _ref = species[_i], spec = _ref[0], score = _ref[1];
        entry = $("<h2>" + spec.Scientific_name + " (" + score + ")</h2>");
        _results.push($('#likely-content').append(entry));
      }
      return _results;
    };

    return App;

  })();

  window.app = new App;

}).call(this);