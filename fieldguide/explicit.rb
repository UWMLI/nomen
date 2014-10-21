#!/usr/bin/env ruby

require 'json'

File.write 'features.json', JSON.dump(`ls features/*/*`.split("\n"))
File.write 'species.json', JSON.dump(`ls species/*`.split("\n"))
