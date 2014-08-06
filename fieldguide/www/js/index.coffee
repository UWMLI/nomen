###
App-o-Mat jQuery Mobile Cordova starter template
https://github.com/app-o-mat/jqm-cordova-template-project
http://app-o-mat.com

MIT License
https://github.com/app-o-mat/jqm-cordova-template-project/LICENSE.md
###

appendTo = (element, muggexpr) ->
  element.append( CoffeeMugg.render(muggexpr, format: no) ).trigger('create')

class App
  constructor: (@datadir) ->
    @library = new Library "#{datadir}/library/"
    @zips = "#{datadir}/zips/"

  onDeviceReady: ->
    FastClick.attach document.body
    @resizeImage()
    $(window).resize => @resizeImage()

  downloadZip: (url, callback = (->)) ->
    result = url.match /\/(\w+).zip$/
    if result?
      folderName = result[1]
      zipFile = "#{@zips}/#{folderName}.zip"
      unzipTo = "#{@library.dir}/#{folderName}"
      resolveLocalFileSystemURL @datadir, (dir) =>
        dir.getDirectory 'zips', {create: yes}, =>
          dir.getDirectory 'library', {create: yes}, (lib) =>
            lib.getDirectory folderName, {create: yes}, =>
              transfer = new FileTransfer()
              transfer.download url, zipFile, (entry) =>
                zip.unzip zipFile, unzipTo, (code) =>
                  if code is 0
                    resolveLocalFileSystemURL zipFile, (zipFileEntry) =>
                      zipFileEntry.remove =>
                        @refreshLibrary callback
                  else
                    throw "Unzip operation on #{zipFile} returned #{code}"
    else
      throw "Couldn't get name of zip file"

  clearLibrary: (callback = (->)) ->
    resolveLocalFileSystemURL @library.dir, (dir) =>
      dir.removeRecursively =>
        @refreshLibrary callback

  refreshLibrary: (callback) ->
    @library.scanLibrary =>
      @clearDataButtons()
      for id, dataset of @library.datasets
        @addDataButton id, dataset.title
      callback()

  deleteDataset: (dataset, callback) ->
    resolveLocalFileSystemURL dataset.dir, (dir) =>
      dir.removeRecursively =>
        @refreshLibrary callback

  clearDataButtons: ->
    $('.dataset-button').remove()

  addDataButton: (id, text) ->
    setFn = "app.setDataset('#{id}', function(){}); return true;"
    appendTo $('#home-content'), ->
      @a '.dataset-button', href: '#dataset', 'data-role': 'button', onclick: setFn, text

  setDataset: (id, callback) ->
    @dataset = @library.datasets[id]
    @dataset.load =>
      @featureRows = for feature, values of allFeatures @dataset.species
        values = (v for v of values).sort()
        for value in values
          display: displayValue value
          image: "#{@dataset.dir}/features/#{feature}/#{feature}-#{value}.png"
          feature: feature
          value: value
      @makeRows()
      @showLikely()
      @fillLikely()
      callback()

  makeRows: ->
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

    @showLikely()
    @fillLikely()

  showLikely: ->
    $('#likely-button').html "#{@getLikely().length} Likely"

  getLikely: ->
    maxScore = Object.keys(@selected).length
    cutoff = maxScore * 0.9
    spec for __, spec of @dataset.species when spec.computeScore(@selected) >= cutoff

  fillLikely: ->
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
              @text "#{spec.name} (#{score})"
            @div '.feature-boxes', ->
              pics = imagesFor spec
              if pics.length is 0
                @div '.feature-box', ->
                  @img '.feature-img', src: 'data/noimage.png'
                  @div '.feature-value', 'No Image'
              else
                for [part, image], ix in pics
                  @a href: "#specimen#{ix}", 'data-transition': 'slide', onclick: setFn, ->
                    @div '.feature-box', ->
                      @img '.feature-img', src: image.toURL()
                      @div '.feature-value', displayValue part

  setSpecies: (name) ->
    @clearPages()
    spec = @dataset.species[name]
    pics = @dataset.imagesForSpecies spec
    if pics.length is 0
      @addPage spec.name, 'data/noimage.png', spec.description, 0
    else
      for [part, image], ix in pics
        @addPage spec.name, image.toURL(), spec.description, ix
    @resizeImage()
    @addSwipes pics.length

  clearPages: ->
    i = 0
    loop
      page = $("#specimen#{i}")
      return if page.length is 0
      page.remove()
      i++

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

  resizeImage: ->
    h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
    $('.specimen-img-box').css('height', "#{h - 100}px")

window.App = App
