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
  constructor: (datadir) ->
    alert 'cons'
    @library = new Library "#{datadir}/library/"
    @zips = "#{datadir}/zips/"
    alert 'after cons'

  onDeviceReady: ->
    FastClick.attach document.body
    alert 'before dl zip'
    @downloadZip 'http://mli.doit.wisc.edu/plants.zip', =>
      alert 'after dl zip'
      @makeRows()
      @showLikely()
      @fillLikely()
      @resizeImage()
      $(window).resize => @resizeImage()
      console.log 'Loaded!'

  downloadZip: (url, callback) ->
    result = url.match /\/(\w+).zip$/
    if result?
      alert 'got zip file name'
      zipFile = "#{@zips}/#{result[1]}.zip"
      unzipTo = "#{@library.dir}/#{result[1]}"
      # TODO: make sure @zips and unzip exist
      transfer = new FileTransfer()
      transfer.download url, zipFile, (entry) =>
        zip.unzip zipFile, unzipTo, (code) =>
          alert code
          if code is 0
            @refreshLibrary callback
          else
            throw "Unzip operation on #{zipFile} returned #{code}"
    else
      throw "Couldn't get name of zip file"

  refreshLibrary: (callback) ->
    @library.scanLibrary =>
      @clearDataButtons()
      for id, dataset of @library.datasets
        @addDataButton id, dataset.name
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
      callback()

  makeRows: ->
    for row in @featureRows
      feature = row[0].feature
      appendTo $('#plants-content'), ->
        @div '.feature-row', ->
          @div '.feature-name', displayValue feature
          @div '.feature-boxes', ->
            for {display, image, value} in row
              toggleFn = "app.toggleElement(this, '#{feature}', '#{value}');"
              @div '.feature-box', onclick: toggleFn, ->
                @img '.feature-img', src: image
                @div '.feature-value', display
    @selected = {}

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
    spec for spec in @species when spec.computeScore(@selected) >= cutoff

  fillLikely: ->
    $('#likely-content').html ''
    species = ([spec, spec.computeScore(@selected)] for __, spec of @dataset.species)
    species.sort (s1, s2) -> s2[1] - s1[1] # sorts by score descending
    dataDir = @dataDir
    for [spec, score] in species[0...10]
      appendTo $('#likely-content'), ->
        setFn = "app.setSpecies('#{spec.name}'); return true;"
        @a href: '#specimen0', 'data-transition': 'slide', onclick: setFn, ->
          @div '.feature-row', ->
            @div '.feature-name', ->
              @text "#{spec.name} (#{score})"
            @div '.feature-boxes', ->
              if spec.pictures.length is 0
                @div '.feature-box', ->
                  @img '.feature-img', src: 'data/noimage.png'
                  @div '.feature-value', 'No Image'
              else
                for image, ix in spec.pictures
                  @a href: "#specimen#{ix}", 'data-transition': 'slide', onclick: setFn, ->
                    @div '.feature-box', ->
                      @img '.feature-img', src: "#{dataDir}/photos/#{image}"
                      result = image.match(/^(\w+)-(\w+)-(\w+)\.(\w+)$/)
                      if result?
                        [match, scientific, part, place, ext] = result
                        @div '.feature-value', displayValue part

  setSpecies: (name) ->
    @clearPages()
    spec = @dataset.species[name]
    if spec.pictures.length is 0
      @addPage spec.name, 'data/noimage.png', spec.description, 0
    else
      for image, ix in spec.pictures
        img = "#{@dataDir}/photos/#{image}"
        @addPage spec.name, img, spec.description, ix
    @resizeImage()
    @addSwipes(spec.pictures.length)

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
