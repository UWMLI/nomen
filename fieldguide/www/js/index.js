// Generated by CoffeeScript 1.7.1

/*
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
 */

(function() {
  var App, appendTo,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  appendTo = function(element, muggexpr) {
    return element.append(CoffeeMugg.render(muggexpr, {
      format: false
    })).trigger('create');
  };

  App = (function() {
    function App() {}

    App.prototype.initialize = function() {
      return this.onDeviceReady();
    };

    App.prototype.onDeviceReady = function() {
      FastClick.attach(document.body);
      this.setBlur();
      $(document).scroll((function(_this) {
        return function() {
          return _this.setBlur();
        };
      })(this));
      $(document).bind('touchmove', (function(_this) {
        return function(e) {
          return _this.setBlur();
        };
      })(this));
      return this.loadSpecies((function(_this) {
        return function() {
          return _this.loadFeatures(function() {
            _this.makeRows();
            _this.showLikely();
            _this.fillLikely();
            return console.log('Loaded!');
          });
        };
      })(this));
    };


    /*
    scrollBlur: ->
      $(window).scroll (e) ->
        console.log($(window).scrollTop())
        $('.blur').css('opacity', $(window).scrollTop() / 150)
     */

    App.prototype.loadSpecies = function(callback) {
      return $.get('data/dataset.csv', (function(_this) {
        return function(str) {
          var spec, _i, _len, _ref;
          _this.species = $.parse(str).results.rows;
          _this.speciesHash = {};
          _ref = _this.species;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            spec = _ref[_i];
            _this.speciesHash[spec.Scientific_name] = spec;
          }
          return callback();
        };
      })(this));
    };

    App.prototype.loadFeatures = function(callback) {
      return $.getJSON('data/plantfeatures.json', (function(_this) {
        return function(json) {
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
        };
      })(this));
    };

    App.prototype.makeRows = function() {
      var feature, row, _i, _len, _ref;
      _ref = this.featureRows;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        feature = row[0].feature;
        appendTo($('#plants-content'), function() {
          return this.div('.feature-row', function() {
            this.div('.feature-name', feature.split('_').join(' '));
            return this.div('.feature-boxes', function() {
              var display, image, toggleFn, value, _j, _len1, _ref1, _results;
              _results = [];
              for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
                _ref1 = row[_j], display = _ref1.display, image = _ref1.image, value = _ref1.value;
                toggleFn = "app.toggleElement(this, '" + feature + "', '" + value + "');";
                _results.push(this.div('.feature-box', {
                  onclick: toggleFn
                }, function() {
                  this.img('.feature-img', {
                    src: image
                  });
                  return this.div('.feature-value', display);
                }));
              }
              return _results;
            });
          });
        });
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
      var score, spec, species, _i, _len, _ref, _ref1, _results;
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
      _ref = species.slice(0, 10);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], spec = _ref1[0], score = _ref1[1];
        _results.push(appendTo($('#likely-content'), function() {
          var setFn;
          setFn = "app.setSpecimen('" + spec.Scientific_name + "')";
          return this.a({
            href: '#specimen',
            'data-transition': 'slide',
            onclick: setFn
          }, function() {
            return this.div('.feature-row', function() {
              this.div('.feature-name', function() {
                return this.text("" + spec.Scientific_name + " (" + score + ")");
              });
              return this.div('.feature-boxes', function() {
                var image, _j, _len1, _ref2, _results1;
                if (spec.Pictures.toString().match(/^\s*$/)) {
                  return this.div('.feature-box', function() {
                    this.img('.feature-img', {
                      src: 'data/noimage.png'
                    });
                    return this.div('.feature-value', 'No Image');
                  });
                } else {
                  _ref2 = spec.Pictures.toString().split(/\s*,\s*/);
                  _results1 = [];
                  for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                    image = _ref2[_j];
                    _results1.push(this.div('.feature-box', function() {
                      var part, place, result, scientific, __;
                      this.img('.feature-img', {
                        src: "data/plantphotos/" + image + ".jpg"
                      });
                      result = image.match(/^(\w+)-(\w+)-(\w+)$/);
                      if (result != null) {
                        __ = result[0], scientific = result[1], part = result[2], place = result[3];
                        return this.div('.feature-value', part.split('_').join(' '));
                      }
                    }));
                  }
                  return _results1;
                }
              });
            });
          });
        }));
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
      $('.specimen-img').css('background-image', "url(" + img + ")");
      $('.specimen-img-fake').prop('src', img);
      return $('.specimen-text').html(desc);
    };

    App.prototype.setBlur = function() {
      var maxScroll, scroll, windowHeight;
      scroll = $(document).scrollTop();
      windowHeight = $(window).height();
      maxScroll = $(document).height() - windowHeight;
      if (maxScroll > 50) {
        $('.blur').css('opacity', (scroll - 50) / (windowHeight * 0.5));
        return console.log(scroll);
      } else {
        return $('.blur').css('opacity', 0);
      }
    };

    return App;

  })();

  window.app = new App;

}).call(this);
