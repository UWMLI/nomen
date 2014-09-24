#!/usr/bin/env ruby

require 'json'

File.write 'features.json', JSON.dump(`echo features/*/*`.split)
File.write 'species.json', JSON.dump(`echo species/*`.split)
