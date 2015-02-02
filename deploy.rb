#!/usr/bin/env ruby

# Enter login details here
url = 'nomenproject.org'
username = ''
password = ''
remote_dir = ''

require 'net/sftp'

def log(s)
  STDERR.puts s
end

def mkdir_f(sftp, dir)
  sftp.mkdir! dir
rescue Net::SFTP::StatusException
  # directory already exists
end

def upload_rf(sftp, from, to)
  return if from == './app/hooks'
  return if from == './app/plugins'
  return if from == './app/platforms'
  return if from == './guides'
  log "Uploading #{from} to #{to}"
  Dir.entries(from).each do |ent|
    next if %w{. .. .DS_Store .gitignore .git deploy.rb}.include? ent
    full_from = "#{from}/#{ent}"
    full_to = "#{to}/#{ent}"
    if File.file?(full_from)
      begin
        sftp.remove! full_to
      rescue Net::SFTP::StatusException
        # file doesn't already exist
      end
      sftp.upload! full_from, full_to
    else
      mkdir_f sftp, full_to
      upload_rf sftp, full_from, full_to
    end
  end
end

Net::SFTP.start(url, username, password: password) do |sftp|
  log " => Connected via SFTP."
  log " => Uploading repo to #{remote_dir}..."
  upload_rf sftp, '.', remote_dir
  log ' => Done!'
end
