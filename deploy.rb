#!/usr/bin/env ruby

# Enter login details here
require '../../fdllogins' # I store mine outside of the repo; edit as necessary
url        = $fdl_logins[:nomen][:url]
username   = $fdl_logins[:nomen][:username]
password   = $fdl_logins[:nomen][:password]
remote_dir = $fdl_logins[:nomen][:remote_dir]

# Enter database details here
nomen_db = {
  host:     $nomen_db[:host],
  user:     $nomen_db[:user],
  password: $nomen_db[:password],
  database: $nomen_db[:database],
  port:     $nomen_db[:port],
}

require 'net/sftp'
require 'tempfile'

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
  log " => Connected #{username}@#{url} via SFTP."
  log " => Uploading repo to #{remote_dir}..."
  upload_rf sftp, '.', remote_dir

  log " => Editing server config to include DB login info..."
  config_location = 'editor/include/config.php'
  db_config = File.read(config_location).split("\n").map do |line|
    %w{host user password database port}.each do |field|
      if line.start_with? "define(#{field.upcase.inspect},"
        line = "define(#{field.upcase.inspect}, #{nomen_db[field.to_sym].inspect});"
      end
    end
    line
  end.join("\n")
  temp_config = Tempfile.new(['config', '.php'])
  begin
    temp_config.puts db_config
    temp_config.close
    log "Uploading #{temp_config.path} to #{remote_dir}/#{config_location}"
    sftp.upload! temp_config.path, "#{remote_dir}/#{config_location}"
  ensure
    temp_config.close!
  end

  log ' => Done!'
end
