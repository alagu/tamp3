require 'rubygems'
require 'mechanize'
require 'pp'

require File.expand_path(File.dirname(__FILE__)) + '/song_downloader.rb'
require File.expand_path(File.dirname(__FILE__)) + '/song_searcher.rb'

song_name = ARGV.join "+"

  def self.search(song_name,options={})
    song_search = SongSearcher.new song_name, options
    songs = song_search.search_and_print_songs
  end

songs = search(song_name)

if songs.length > 0
  print "Filter based on \n 1. Movie name \n 2. Singer name \n 3.if sufficient with result please press enter\n"
  filter = STDIN.gets
  if filter.chomp.to_i == 1
    search(song_name,{:movie_name=>song_name})
  elsif filter.chomp.to_i == 2
    search(song_name,{:singer_name=>song_name})
  end 
  
  print "Which one to download (1-#{songs.length}) ? "
  index         = STDIN.gets 
  index         = index.chomp.to_i
  selected_song = songs[index-1]
  song_id       = selected_song[:id]
  song_name     = selected_song[:name]
  
  song_downloader = SongDownloader.new(selected_song)
  song_downloader.download
end
