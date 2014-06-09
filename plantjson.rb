#!/usr/bin/env ruby

require 'json'

dir = ARGV[0] || '.'
hash = {}
Dir.entries(dir).each do |feature|
  featuredir = "#{dir}/#{feature}"
  next unless File.directory?(featuredir) and not ['.', '..'].include?(feature)
  values = []
  Dir.entries(featuredir).each do |image|
    image.match(/\A#{Regexp.escape(feature)}-(.+)\.png\Z/) do |md|
      values << md[1]
    end
  end
  hash[feature] = values unless values.empty?
end
puts hash.to_json
