require 'rubygems'
require 'rubygems'
require 'mechanize'
require 'pp'
require './tamilmp3.rb'

song_name = ARGV.join "+"
song_search = SongSearch.new song_name
songs = song_download.search_and_print_songs

if songs.length > 0
  print "Which one to download (1-#{songs.length}) ? "
  index   = STDIN.gets 
  index   = index.chomp.to_i
  song_id = songs[index-1][:id]
  

end