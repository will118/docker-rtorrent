#!/usr/local/bin/ruby

require 'net/http'

# helpers
def gb_size(path)
  File.size(path).to_f / (1024 * 1000000)
end

def move_file(file_path, destination_folder)
  file_name = File.basename file_path
  File.rename file_path, "#{destination_folder}/#{file_name}"
  "#{file_name} moved to #{destination_folder}"
end

# args
DESTINATION_FOLDER_NAME = ARGV[0]
SOURCE_PATH = ARGV[1]
TORRENT_HASH = ARGV[2]

# tell server to delete torrent from rtorrent
rtorrent_uri = URI('http://arr:3333/')
Net::HTTP.post_form(rtorrent_uri, hash: TORRENT_HASH)

# unrar any stuff
Dir.glob("#{SOURCE_PATH}/**/*.rar")
  .select { |x| File.file? x }
  .each { |path| puts `unrar e -o- "#{path}" "#{File.dirname path}"` }

# delete rars
Dir.glob("#{SOURCE_PATH}/**/*.r??")
  .select { |file| gb_size(file) < 0.2 }
  .each { |file| File.delete(file) }

# move any/everything
DESTINATION_FULL_PATH = "/plexdata/#{DESTINATION_FOLDER_NAME}"

# move whole folder because its easier for plex
move_file(SOURCE_PATH, DESTINATION_FULL_PATH)

# delete the source
`rm -rf #{SOURCE_PATH}`
