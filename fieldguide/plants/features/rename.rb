#!/usr/bin/env ruby

ls = Dir.entries('.').select { |s| s[0..0] != '.' && File.directory?(s) }
ls.each do |dir|
  ls2 = Dir.entries(dir).select { |s| s[0..0] != '.' }
  ls2.each do |f|
    f.match(/^#{dir}-(.+)$/) do |md|
      f2 = md[1]
      `mv #{dir}/#{f} #{dir}/#{f2}`
    end
  end
end
