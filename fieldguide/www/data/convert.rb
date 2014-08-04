#!/usr/bin/env ruby
require 'csv'
rows = CSV.read('dataset.csv', headers: true)
features = %w{
  Flower_color
  Flower_arrangement
  Flower_symmetry
  Number_flower_parts
  Flowering_month
  Leaf_arrangement
  Leaf_type
  Leaf_shape
  Leaf_margin
  Leaf_venation
  Stem_shape
  Stem_texture
  Growth_form
  Distribution
}

# Print header
puts CSV.generate_line [
  'name',
  'display_name',
  'description',
  'pictures',
  *features.map(&:downcase),
]

# Print rows
rows.each do |row|
  puts CSV.generate_line [
    row['Scientific_name'],
    row['Common_name'].split(',')[0].strip,
    row['Description'],
    (row['Pictures'] || '').split(',').map { |f| f.strip.downcase + '.jpg' }.join(','),
    *features.map { |f| row[f] },
  ]
end
