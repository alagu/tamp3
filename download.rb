require 'rubygems'
require './tamilmp3.rb'

song_name = ARGV.join "+"
song_download = SongDownload.new song_name
songs = song_download.search_and_print_songs