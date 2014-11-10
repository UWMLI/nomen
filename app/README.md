This is a browser and mobile ([Cordova][]) app, written with [CoffeeScript][].

  [Cordova]: http://cordova.apache.org/
  [CoffeeScript]: http://coffeescript.org/

  * To set up the platform and plugins for Cordova, run `./setup`. This creates
    an iOS project and downloads/installs all the needed plugins.

  * The `Makefile` handles compiling the CoffeeScript and creating download
    archives of the guides. Run `make js` and `make zips` respectively.

  * The CoffeeScript files use an extra syntax feature implemented by
    `action-arrow.rb`, where `->>` or `=>>` adds an extra "return" at the
    end of their function body. This disables CoffeeScript's "return the last
    expression" behavior. The `Makefile` is set up to run this script before
    translating to JS, but you can also just replace the double arrow with a
    single arrow, with no semantic difference.

# Browser mode

To use in a browser, find the variable `readOnly` near the bottom of
`www/index.html`, the one used when not running in Cordova. Point this to a JSON
file with an array of relative or absolute URLs to guide directories. You can
also point it at `/editor/www/library.php` to link directly to the Editor.

The guide directories must also have files `features.json` and `species.json`
containing lists of images; these are generated either by the Editor site, or by
`/guides/explicit.rb`.

# Mobile app mode

To use as a mobile app, firstly you can "build in" guides to the app by
following the same instructions as above for the browser. Make sure you edit the
`readOnly` variable found in the Cordova section.

Secondly, you can set up a remote server which the app queries and downloads
guides from. Edit the `remoteURL` variable to point to a JSON file like that
served by `/editor/www/api.php`. Then build with Cordova and use the "Download"
feature in the app to transfer guides to the phone storage.
