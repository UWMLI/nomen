#!/usr/bin/env ruby

# Deletes all existing zip files and makes a new one for each guide folder.

require 'fileutils'

def system_(*args)
  p args
  unless system(*args)
    raise IOError, "Command #{args.inspect} returned #{$?.exitstatus}"
  end
end

keep_files = %w{
  species/\\*
  features/\\*
  info.json
  species.csv
  features.json
  species.json
  icon.png
  icon.jpg
  icon.jpeg
}

system_ 'rm -rf *.zip'
Dir['*/'].each do |dir|
  dir = dir[0..-2]
  zip = "#{dir}.zip"
  FileUtils.cd(dir) do
    system_ "zip -r ../#{zip} . -i #{keep_files.join(' ')}"
  end
end
