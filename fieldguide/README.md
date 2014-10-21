This is a browser and mobile ([Cordova][]) app, written with [CoffeeScript][].

  [Cordova]: http://cordova.apache.org/
  [CoffeeScript]: http://coffeescript.org/

  * To set up the platform and plugins for Cordova, run `./setup`. This creates
    an iOS project and downloads/installs all the needed plugins.

  * The `Makefile` handles compiling the CoffeeScript and creating download
    archives of the datasets. Run `make js` and `make zips` respectively.

  * The CoffeeScript files use an extra syntax feature implemented by
    `action-arrow.rb`, where `->>` or `=>>` adds an extra "return" at the
    end of their function body. This disables CoffeeScript's "return the last
    expression" behavior. The `Makefile` is set up to run this script before
    translating to JS, but you can also just replace the double arrow with a
    single arrow, with no semantic difference.

# Browser mode

To use in a browser, make a file `www/library.json` with an array of relative or
absolute URLs to directories, like so:

    ["../datasets/plants", "../datasets/football"]

Then, run `explicit.rb` in each of the dataset directories to generate files
`features.json` and `species.json`. Finally, browse to `www/index.html`.

# Mobile app mode

To use as a mobile app, firstly you can "build in" datasets to the app by
following the same instructions as above for the browser.

Secondly, you can set up a remote server which the app queries and downloads
datasets from. Edit the URL near the bottom of `www/index.html` which points to
a JSON file. This JSON file should have the format of `remote/list.json`. Then
build with Cordova and use the "Download" feature in the app.
