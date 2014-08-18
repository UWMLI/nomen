#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'nokogiri'
require 'csv'

def jsonURL(url)
  JSON.parse open(url).read
end

class Pokemon
  def initialize(number)
    @number = number
    @obj = jsonURL "http://pokeapi.co/api/v1/pokemon/#{number}/"
  end
  attr_reader :number, :obj

  def method_missing(sym, *args, &blk)
    @obj[sym.to_s]
  end

  def imageURL
    name = case self.name
    when /^Nidoran/
      'Nidoran'
    when "Farfetch'd"
      'Farfetch%27d'
    else
      self.name
    end
    filename = "%03d%s.png" % [@number, name]
    url = "http://archives.bulbagarden.net/w/api.php?format=xml&action=query&list=allimages&aifrom=#{filename}&aito=#{filename}"
    xml = Nokogiri::XML open(url).read
    xml.css('img')[0]['url']
  end

  def description
    json = jsonURL "http://pokeapi.co#{@obj['descriptions'][0]['resource_uri']}"
    json['description']
  end
end

`mkdir -p pokemon`
`mkdir -p pokemon/features`
`mkdir -p pokemon/species`

rows = []
# CSV header
rows << %w{
  name
  description
  height
}

pokemon = (1..151).map { |n| puts "API request: #{n}"; Pokemon.new(n) }

class Array
  def make_groups(n)
    self.each_slice( [1, (self.length.to_f / n).floor].max ).map do |ary|
      ary[0] .. ary[-1]
    end
  end
end

height_groups = pokemon.map(&:height).map(&:to_i).uniq.sort.make_groups(6)

pokemon.each do |p|
  rows << [
    p.name,
    p.description,
    height_groups.select { |range| range.include?(p.height) }.map do |range|
      if range.min == range.max
        "#{range.min.to_s}"
      else
        "#{range.min} to #{range.max}"
      end
    end[0],
  ]
  image = "pokemon/species/#{p.name.downcase}-art.png"
  unless File.exists? image
    puts "Getting image: #{p.number}"
    open(image, 'wb') do |f|
      f << open(p.imageURL).read
    end
  end
end

CSV.open('pokemon/species.csv', 'wb') do |csv|
  rows.each do |row|
    csv << row
  end
end
