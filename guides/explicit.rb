#!/usr/bin/env ruby

# Meant to be run from one of the guide folders.
# Makes lists of all the feature and species images.

require 'json'

File.write 'features.json', JSON.dump(Dir['features/*/*'])
File.write 'species.json', JSON.dump(Dir['species/*'])
