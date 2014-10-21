#!/usr/bin/env ruby

require 'csv'
orig = CSV.read('species-original.csv', headers: true)
headers = %w{Name Description Conference State} + ["Primary Colors", "Mascot Genre"]
CSV.open('species.csv', 'wb') do |csv|
  csv << headers
  orig.each do |row|
    csv << headers.map{ |col| row[col] }
  end
end
