// Generated by CoffeeScript 1.7.1

/*
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
 */

(function() {
  var App, appendTo;

  appendTo = function(element, muggexpr) {
    return element.append(CoffeeMugg.render(muggexpr, {
      format: false
    })).trigger('create');
  };

  App = (function() {
    function App(datadir) {
      this.library = new Library("" + datadir + "/library/");
      this.zips = "" + datadir + "/zips/";
    }

    App.prototype.onDeviceReady = function() {
      FastClick.attach(document.body);
      $(window).resize((function(_this) {
        return function() {
          return _this.resizeImage();
        };
      })(this));
      return this.downloadZip('http://mli.doit.wisc.edu/plants.zip', (function(_this) {
        return function() {};
      })(this));
    };

    App.prototype.downloadZip = function(url, callback) {
      var result, transfer, unzipTo, zipFile;
      result = url.match(/\/(\w+).zip$/);
      if (result != null) {
        zipFile = "" + this.zips + "/" + result[1] + ".zip";
        unzipTo = "" + this.library.dir + "/" + result[1];
        transfer = new FileTransfer();
        return transfer.download(url, zipFile, (function(_this) {
          return function(entry) {
            return zip.unzip(zipFile, unzipTo, function(code) {
              if (code === 0) {
                return _this.refreshLibrary(callback);
              } else {
                throw "Unzip operation on " + zipFile + " returned " + code;
              }
            });
          };
        })(this));
      } else {
        throw "Couldn't get name of zip file";
      }
    };

    App.prototype.refreshLibrary = function(callback) {
      return this.library.scanLibrary((function(_this) {
        return function() {
          var dataset, id, _ref;
          _this.clearDataButtons();
          _ref = _this.library.datasets;
          for (id in _ref) {
            dataset = _ref[id];
            _this.addDataButton(id, dataset.title);
          }
          return callback();
        };
      })(this));
    };

    App.prototype.deleteDataset = function(dataset, callback) {
      return resolveLocalFileSystemURL(dataset.dir, (function(_this) {
        return function(dir) {
          return dir.removeRecursively(function() {
            return _this.refreshLibrary(callback);
          });
        };
      })(this));
    };

    App.prototype.clearDataButtons = function() {
      return $('.dataset-button').remove();
    };

    App.prototype.addDataButton = function(id, text) {
      var setFn;
      setFn = "app.setDataset('" + id + "', function(){}); return true;";
      return appendTo($('#home-content'), function() {
        return this.a('.dataset-button', {
          href: '#dataset',
          'data-role': 'button',
          onclick: setFn
        }, text);
      });
    };

    App.prototype.setDataset = function(id, callback) {
      this.dataset = this.library.datasets[id];
      return this.dataset.load((function(_this) {
        return function() {
          var feature, v, value, values;
          _this.featureRows = (function() {
            var _ref, _results;
            _ref = allFeatures(this.dataset.species);
            _results = [];
            for (feature in _ref) {
              values = _ref[feature];
              values = ((function() {
                var _results1;
                _results1 = [];
                for (v in values) {
                  _results1.push(v);
                }
                return _results1;
              })()).sort();
              _results.push((function() {
                var _i, _len, _results1;
                _results1 = [];
                for (_i = 0, _len = values.length; _i < _len; _i++) {
                  value = values[_i];
                  _results1.push({
                    display: displayValue(value),
                    image: "" + this.dataset.dir + "/features/" + feature + "/" + feature + "-" + value + ".png",
                    feature: feature,
                    value: value
                  });
                }
                return _results1;
              }).call(this));
            }
            return _results;
          }).call(_this);
          _this.makeRows();
          _this.showLikely();
          _this.fillLikely();
          _this.resizeImage();
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
        appendTo($('#dataset-content'), function() {
          return this.div('.feature-row', function() {
            this.div('.feature-name', displayValue(feature));
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
      this.selected = {};
      return $('.feature-value').removeClass('selected');
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

    App.prototype.showLikely = function() {
      return $('#likely-button').html("" + (this.getLikely().length) + " Likely");
    };

    App.prototype.getLikely = function() {
      var cutoff, maxScore, spec, __, _ref, _results;
      maxScore = Object.keys(this.selected).length;
      cutoff = maxScore * 0.9;
      _ref = this.dataset.species;
      _results = [];
      for (__ in _ref) {
        spec = _ref[__];
        if (spec.computeScore(this.selected) >= cutoff) {
          _results.push(spec);
        }
      }
      return _results;
    };

    App.prototype.fillLikely = function() {
      var imagesFor, score, spec, species, __, _i, _len, _ref, _ref1, _results;
      $('#likely-content').html('');
      species = (function() {
        var _ref, _results;
        _ref = this.dataset.species;
        _results = [];
        for (__ in _ref) {
          spec = _ref[__];
          _results.push([spec, spec.computeScore(this.selected)]);
        }
        return _results;
      }).call(this);
      species.sort(function(s1, s2) {
        return s2[1] - s1[1];
      });
      imagesFor = (function(_this) {
        return function(spec) {
          return _this.dataset.imagesForSpecies(spec);
        };
      })(this);
      _ref = species.slice(0, 10);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], spec = _ref1[0], score = _ref1[1];
        _results.push(appendTo($('#likely-content'), function() {
          var setFn;
          setFn = "app.setSpecies('" + spec.name + "'); return true;";
          return this.a({
            href: '#specimen0',
            'data-transition': 'slide',
            onclick: setFn
          }, function() {
            return this.div('.feature-row', function() {
              this.div('.feature-name', function() {
                return this.text("" + spec.name + " (" + score + ")");
              });
              return this.div('.feature-boxes', function() {
                var image, ix, part, pics, _j, _len1, _ref2, _results1;
                pics = imagesFor(spec);
                if (pics.length === 0) {
                  return this.div('.feature-box', function() {
                    this.img('.feature-img', {
                      src: 'data/noimage.png'
                    });
                    return this.div('.feature-value', 'No Image');
                  });
                } else {
                  _results1 = [];
                  for (ix = _j = 0, _len1 = pics.length; _j < _len1; ix = ++_j) {
                    _ref2 = pics[ix], part = _ref2[0], image = _ref2[1];
                    _results1.push(this.a({
                      href: "#specimen" + ix,
                      'data-transition': 'slide',
                      onclick: setFn
                    }, function() {
                      return this.div('.feature-box', function() {
                        this.img('.feature-img', {
                          src: image.toURL()
                        });
                        return this.div('.feature-value', displayValue(part));
                      });
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

    App.prototype.setSpecies = function(name) {
      var image, ix, part, pics, spec, _i, _len, _ref;
      this.clearPages();
      spec = this.dataset.species[name];
      pics = this.dataset.imagesForSpecies(spec);
      if (pics.length === 0) {
        this.addPage(spec.name, 'data/noimage.png', spec.description, 0);
      } else {
        for (ix = _i = 0, _len = pics.length; _i < _len; ix = ++_i) {
          _ref = pics[ix], part = _ref[0], image = _ref[1];
          this.addPage(spec.name, image.toURL(), spec.description, ix);
        }
      }
      this.resizeImage();
      return this.addSwipes(pics.length);
    };

    App.prototype.clearPages = function() {
      var i, page;
      i = 0;
      while (true) {
        page = $("#specimen" + i);
        if (page.length === 0) {
          return;
        }
        page.remove();
        i++;
      }
    };

    App.prototype.addPage = function(name, img, desc, ix) {
      return appendTo($('body'), function() {
        return this.div("#specimen" + ix + " .specimen", {
          'data-role': 'page'
        }, function() {
          this.div({
            'data-role': 'header',
            'data-position': 'fixed',
            'data-tap-toggle': 'false'
          }, function() {
            this.h1(name);
            return this.a('.ui-btn-left', {
              'href': '#likely',
              'data-icon': 'arrow-l',
              'data-transition': 'slide',
              'data-direction': 'reverse'
            }, 'Back');
          });
          return this.div('.ui-content .specimen-content', {
            'data-role': 'main'
          }, function() {
            this.div('.specimen-img-box', function() {
              this.div('.specimen-img', {
                style: "background-image: url(" + img + ");"
              }, '');
              this.div('.specimen-img .blur', {
                style: "background-image: url(" + img + ");"
              }, '');
              return this.div('.specimen-img-gradient', '');
            });
            return this.div('.specimen-text-box', function() {
              return this.div('.specimen-text', desc);
            });
          });
        });
      });
    };

    App.prototype.addSwipes = function(imgs) {
      var ix, _fn, _i, _j, _ref, _ref1, _results;
      if (imgs >= 2) {
        _fn = function(ix) {
          return $("#specimen" + ix + " .specimen-img-box").on('swipeleft', function() {
            return $.mobile.changePage("#specimen" + (ix + 1), {
              transition: "slide"
            });
          });
        };
        for (ix = _i = 0, _ref = imgs - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; ix = 0 <= _ref ? ++_i : --_i) {
          _fn(ix);
        }
        _results = [];
        for (ix = _j = 1, _ref1 = imgs - 1; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; ix = 1 <= _ref1 ? ++_j : --_j) {
          _results.push((function(ix) {
            return $("#specimen" + ix + " .specimen-img-box").on('swiperight', function() {
              return $.mobile.changePage("#specimen" + (ix - 1), {
                transition: "slide",
                reverse: true
              });
            });
          })(ix));
        }
        return _results;
      }
    };

    App.prototype.resizeImage = function() {
      var h;
      h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
      return $('.specimen-img-box').css('height', "" + (h - 100) + "px");
    };

    return App;

  })();

  window.App = App;

}).call(this);
