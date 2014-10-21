This is a desktop and mobile ([Cordova][]) app, written with [CoffeeScript][].

  [Cordova]: http://cordova.apache.org/
  [CoffeeScript]: http://coffeescript.org/

  * To set up the platform and plugins for Cordova, run `./setup`. This creates
    an iOS project and downloads/installs all the needed plugins.

  * The `Makefile` handles compiling the CoffeeScript and creating download
    archives of the datasets. Run `make js` and `make zips` respectively.

  * The CoffeeScript files use an extra syntax feature implemented by
    `action-arrow.{rb,hs}`, where `->>` or `=>>` adds an extra "return" at the
    end of their function body. This disables CoffeeScript's "return the last
    expression" behavior. The `Makefile` is set up to run this script before
    translating to JS, but you can also just replace the double arrow with a
    single arrow, with no semantic difference.

  * At the bottom of `index.html` are the URLs it expects to find datasets at
    for either desktop or mobile use. For read-only datasets built into the
    webpage or mobile app, make a file `www/list.json` with an array of relative
    URLs to directories, like so:

        ["../plants", "../football"]

    For datasets downloadable to the mobile app, a URL is queried which should
    point a file like the included `list.json`. Edit this URL in `index.html`
    as necessary.
