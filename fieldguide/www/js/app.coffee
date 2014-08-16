###
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
###

'use strict'

# Shortcut for
# 1. using CoffeeMugg to generate some HTML
# 2. appending it to a JQuery element
# 3. directing JQuery Mobile to perform any appearance triggers
#    (for example restyling links into buttons, etc.)
appendTo = (element, muggexpr) ->
  element.append( CoffeeMugg.render(muggexpr, format: no) ).trigger('create')

class App
  constructor: (@datadir) ->
    @library = new Library datadir
    @remote = new Remote datadir, 'http://mli.doit.wisc.edu/list.json'

  # Called after all the Cordova APIs are ready.
  onDeviceReady: ->
    FastClick.attach document.body
    @resizeImage()
    $(window).resize => @resizeImage()
    @refreshLibrary()

  syncRemote: (callback = (->)) ->
    @remote.downloadList =>
      @clearRemoteButtons()
      for dataset in @remote.datasets
        @addRemoteButton dataset.id, dataset.title
      callback()

  clearRemoteButtons: ->
    $('#remote-content').html ''

  # Add a button for a new dataset to the home screen.
  addRemoteButton: (id, text) ->
    setFn = "app.downloadZip('#{id}');"
    appendTo $('#remote-content'), ->
      @a '.remote-button', 'data-role': 'button', onclick: setFn, text

  # Download a dataset from the remote, unzip it, and add a button for it to the
  # home screen (by calling refreshLibrary).
  downloadZip: (id, callback = (->)) ->
    @library.makeDir =>
      @remote.downloadList =>
        @remote.downloadDataset id, @library, =>
          @refreshLibrary callback

  # Delete all datasets from the file system, by removing the whole library
  # folder recursively.
  clearLibrary: (callback = (->)) ->
    @library.deleteDir =>
      @refreshLibrary callback

  # Ensure the buttons on the home screen accurately reflect the datasets
  # we have in the file system.
  refreshLibrary: (callback = (->)) ->
    @library.scanLibrary =>
      @clearDataButtons()
      for id, dataset of @library.datasets
        @addDataButton id, dataset.title
      callback()

  # Delete the given dataset from the device's file system.
  # Also deletes the button by calling refreshLibrary.
  deleteDataset: (dataset, callback) ->
    resolveLocalFileSystemURL dataset.dir, (dir) =>
      dir.removeRecursively =>
        @refreshLibrary callback

  # Clear any existing dataset buttons on the home screen.
  clearDataButtons: ->
    $('.dataset-button').remove()

  # Add a button for a new dataset to the home screen.
  addDataButton: (id, text) ->
    setFn = "app.setDataset('#{id}', function(){}); return true;"
    appendTo $('#home-content'), ->
      @a '.dataset-button', href: '#dataset', 'data-role': 'button', onclick: setFn, text

  # Executed when the user opens a dataset from the home screen.
  setDataset: (id, callback) ->
    @dataset = @library.datasets[id]
    @dataset.load =>
      @featureRows = for feature, values of @dataset.features
        for value in Object.keys(values).sort()
          display: displayValue value
          image: "#{@dataset.dir}/features/#{feature}/#{value}.png"
          feature: feature
          value: value
      $('#dataset-header').html @dataset.title
      @makeFeatureRows()
      @showHowMany()
      @fillLikelyPage()
      callback()

  # Fill the features page with rows of possible filtering criteria.
  makeFeatureRows: ->
    for row in @featureRows
      feature = row[0].feature
      appendTo $('#dataset-content'), ->
        @div '.feature-row', ->
          @div '.feature-name', displayValue feature
          @div '.feature-boxes', ->
            for {display, image, value} in row
              toggleFn = "app.toggleElement(this, '#{feature}', '#{value}');"
              @div '.feature-box', onclick: toggleFn, ->
                @img '.feature-img', src: image
                @div '.feature-value', display
    @selected = {}
    $('.feature-value').removeClass 'selected'

  # Toggle a feature-value's selection (both in the app, and in appearance).
  toggleElement: (element, feature, value) ->
    @selected[feature] ?= {}

    if @selected[feature][value]
      delete @selected[feature][value]
    else
      @selected[feature][value] = true

    if Object.keys(@selected[feature]).length is 0
      delete @selected[feature]

    value = $(element).find '.feature-value'
    if value.hasClass 'selected'
      value.removeClass 'selected'
    else
      value.addClass 'selected'

    @showHowMany()
    @fillLikelyPage()

  # Update the "X Likely" button in the upper-right of the features page.
  showHowMany: ->
    $('#likely-button').html "#{@getLikely().length} Likely"

  # Compute how many species roughly match the criteria the user selected.
  getLikely: ->
    maxScore = Object.keys(@selected).length
    cutoff = maxScore * 0.9
    spec for __, spec of @dataset.species when spec.computeScore(@selected) >= cutoff

  # Fill the "likely" page with rows of species images.
  fillLikelyPage: ->
    $('#likely-content').html ''
    species =
      [spec, spec.computeScore(@selected)] for __, spec of @dataset.species
    species.sort (s1, s2) -> s2[1] - s1[1] # sorts by score descending
    imagesFor = (spec) =>
      @dataset.imagesForSpecies spec
    for [spec, score] in species[0...10]
      appendTo $('#likely-content'), ->
        setFn = "app.setSpecies('#{spec.name}'); return true;"
        @a href: '#specimen0', 'data-transition': 'slide', onclick: setFn, ->
          @div '.feature-row', ->
            @div '.feature-name', ->
              @text "#{spec.display_name} (#{score})"
            @div '.feature-boxes', ->
              pics = imagesFor spec
              if pics.length is 0
                @div '.feature-box', ->
                  @img '.feature-img', src: 'img/noimage.png'
                  @div '.feature-value', 'No Image'
              else
                for [part, image], ix in pics
                  @a href: "#specimen#{ix}", 'data-transition': 'slide', onclick: setFn, ->
                    @div '.feature-box', ->
                      @img '.feature-img', src: image.toURL()
                      @div '.feature-value', displayValue part

  # Executed when the user clicks on a species button from the "likely" page.
  # Clear existing species pages, and make new ones for the selected species.
  setSpecies: (name) ->
    @clearPages()
    spec = @dataset.species[name]
    pics = @dataset.imagesForSpecies spec
    if pics.length is 0
      @addPage spec.display_name, 'img/noimage.png', spec.description, 0
    else
      for [part, image], ix in pics
        @addPage spec.display_name, image.toURL(), spec.description, ix
    @resizeImage()
    @addSwipes pics.length

  # Remove all the current JQuery Mobile pages for species images.
  clearPages: ->
    i = 0
    loop
      page = $("#specimen#{i}")
      return if page.length is 0
      page.remove()
      i++

  # Add a JQuery Mobile page containing one of a species' images.
  addPage: (name, img, desc, ix) ->
    appendTo $('body'), ->
      @div "#specimen#{ix} .specimen", 'data-role': 'page', ->
        @div 'data-role': 'header', 'data-position': 'fixed', 'data-tap-toggle': 'false', ->
          @h1 name
          @a '.ui-btn-left', 'href': '#likely', 'data-icon': 'arrow-l', 'data-transition': 'slide', 'data-direction': 'reverse', 'Back'
        @div '.ui-content .specimen-content', 'data-role': 'main', ->
          @div '.specimen-img-box', ->
            @div '.specimen-img', style: "background-image: url(#{img});", ''
            @div '.specimen-img .blur', style: "background-image: url(#{img});", ''
            @div '.specimen-img-gradient', ''
          @div '.specimen-text-box', ->
            @div '.specimen-text', desc

  # Add swipe handlers to the image pages, so you can swipe left and right
  # to move through a species' images.
  addSwipes: (imgs) ->
    if imgs >= 2
      for ix in [0 .. imgs - 2]
        do (ix) ->
          $("#specimen#{ix} .specimen-img-box").on 'swipeleft', ->
            # swipeleft means move one image over to the right
            $.mobile.changePage "#specimen#{ix + 1}", { transition: "slide" }
      for ix in [1 .. imgs - 1]
        do (ix) ->
          $("#specimen#{ix} .specimen-img-box").on 'swiperight', ->
            # swiperight means move one image over to the left
            $.mobile.changePage "#specimen#{ix - 1}", { transition: "slide", reverse: true }

  # Dynamically resize the species images so they roughly fill the screen.
  # This gets called whenever a new species is selected (after its image pages
  # are added), or whenever the window is resized (e.g. device is rotated),
  # see `onDeviceReady`.
  resizeImage: ->
    h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
    $('.specimen-img-box').css('height', "#{h - 100}px")

window.App = App
