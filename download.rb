require 'rubygems'
require 'mechanize'
require 'pp'

require File.expand_path(File.dirname(__FILE__)) + '/song_downloader.rb'
require File.expand_path(File.dirname(__FILE__)) + '/song_searcher.rb'

song_name = ARGV.join "+"
song_search = SongSearcher.new song_name
songs = song_search.search_and_print_songs

if songs.length > 0
  print "Which one to download (1-#{songs.length}) ? "
  index         = STDIN.gets 
  index         = index.chomp.to_i
  selected_song = songs[index-1]
  song_id       = selected_song[:id]
  song_name     = selected_song[:name]
  
  song_downloader = SongDownloader.new(song_id, song_name)
  song_downloader.download
end