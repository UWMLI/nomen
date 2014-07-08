
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

    /*
      scrollBlur: ->
        $(window).scroll (e) ->
          console.log($(window).scrollTop())
          $('.blur').css('opacity', $(window).scrollTop() / 150)
    */


    App.prototype.loadSpecies = function(callback) {
      var _this = this;
      return $.get('data/dataset.csv', function(str) {
        var spec, _i, _len, _ref;
        _this.species = $.parse(str).results.rows;
        _this.speciesHash = {};
        _ref = _this.species;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          spec = _ref[_i];
          _this.speciesHash[spec.Scientific_name] = spec;
        }
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
        htmlRow.append("<div class='feature-name'>" + (feature.split('_').join(' ')) + "</div>").trigger("create");
        for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
          _ref1 = row[_j], display = _ref1.display, image = _ref1.image, value = _ref1.value;
          htmlBox = $('<div />', {
            "class": 'feature-box',
            onclick: "app.toggleElement(this, " + (JSON.stringify(feature)) + ", " + (JSON.stringify(value)) + ");"
          });
          htmlBox.append("<div class='feature-value'>" + display + "</div>").trigger("create");
          htmlBox.append($('<img />', {
            "class": 'feature-img',
            src: image
          })).trigger("create");
          htmlRow.append(htmlBox).trigger("create");
        }
        container.append(htmlRow).trigger("create");
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
            _results.push(v.toLowerCase());
          }
          return _results;
        })();
        speciesValues = (function() {
          var _i, _len, _ref1, _results;
          _ref1 = species[feature].toString().split(/\s*,\s*/);
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            v = _ref1[_i];
            _results.push(v.toLowerCase());
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
      var container, htmlBox, htmlLink, htmlRow, image, img, part, place, result, scientific, score, setFn, spec, species, __, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
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
      container = $('#likely-content');
      _ref = species.slice(0, 10);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], spec = _ref1[0], score = _ref1[1];
        htmlRow = $('<div />', {
          "class": 'feature-row'
        });
        htmlRow.append("<div class='feature-name'>" + spec.Scientific_name + " (" + score + ")</div>").trigger("create");
        if (spec.Pictures.toString().match(/^\s*$/)) {
          htmlBox = $('<div class="feature-box" />');
          htmlBox.append("<div class='feature-value'>No Image</div>").trigger("create");
          htmlBox.append($('<img />', {
            "class": 'feature-img',
            src: 'data/noimage.png'
          })).trigger("create");
          htmlRow.append(htmlBox).trigger("create");
        } else {
          _ref2 = spec.Pictures.toString().split(/\s*,\s*/);
          for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
            image = _ref2[_j];
            img = "data/plantphotos/" + image + ".jpg";
            htmlBox = $('<div class="feature-box" />');
            result = image.match(/^([A-Za-z0-9_]+)-([A-Za-z0-9_]+)-([A-Za-z0-9_]+)$/);
            if (result != null) {
              __ = result[0], scientific = result[1], part = result[2], place = result[3];
              part = part.split('_').join(' ');
              htmlBox.append("<div class='feature-value'>" + part + "</div>").trigger("create");
            }
            htmlBox.append($('<img />', {
              "class": 'feature-img',
              src: img
            })).trigger("create");
            htmlRow.append(htmlBox).trigger("create");
          }
        }
        setFn = "app.setSpecimen(" + (JSON.stringify(spec.Scientific_name)) + ")";
        htmlLink = $("<a href=\"#specimen\" data-transition=\"slide\" onclick='" + setFn + "' />");
        htmlLink.append(htmlRow).trigger("create");
        _results.push(container.append(htmlLink).trigger("create"));
      }
      return _results;
    };

    App.prototype.setSpecimen = function(name) {
      var desc, id, img, spec;
      spec = this.speciesHash[name];
      if (spec.Pictures.toString().match(/^\s*$/)) {
        img = 'data/noimage.png';
      } else {
        id = spec.Pictures.toString().split(/\s*,\s*/)[0];
        img = "data/plantphotos/" + id + ".jpg";
      }
      desc = spec.Description;
      $('#specimen-name').html(name);
      $('.specimen-img').prop('src', img);
      return $('.specimen-text').html(desc);
    };

    return App;

  })();

  window.app = new App;

}).call(this);