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
    @obj[sym]
  end

  def imageURL
    filename = "%03d%s.png" % [@number, @obj['name']]
    url = "http://archives.bulbagarden.net/w/api.php?format=xml&action=query&list=allimages&aifrom=#{filename}&aito=#{filename}"
    xml = Nokogiri::XML open(url).read
    xml.css('img')[0]['url']
  end

  def description
    json = jsonURL "http://pokeapi.co#{@obj['descriptions'][0]['resource_uri']}"
    json['description']
  end
end

`rm -rf pokemon`
`mkdir pokemon`
`mkdir pokemon/features`
`mkdir pokemon/species`

rows = []
# CSV header
rows << %w{
  name
  description
}

(1..5).each do |n|
  p = Pokemon.new(n)
  rows << [
    p.obj['name'],
    p.description,
  ]
  open("pokemon/species/#{p.obj['name'].downcase}-art.png", 'wb') do |f|
    f << open(p.imageURL).read
  end
end

CSV.open('pokemon/species.csv', 'wb') do |csv|
  rows.each do |row|
    csv << row
  end
end
