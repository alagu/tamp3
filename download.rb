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

def self.get_input_again (songs)
  if songs.length == 0
    return
  end
  print "Which one to download [1-#{songs.length}]? "
  index = STDIN.gets 
  index.split(",").map {|song_list| song_list.to_i }
end

if songs.length > 0
  
  puts "Filters: m=movie; s=singer"
  print "Which one to download [1-#{songs.length},m,s]? "
  index         = STDIN.gets 
  index         = index.chomp

  if index == "m"
    songs = search(song_name,{:movie_name=>song_name})
    song_list = get_input_again songs
  elsif index == "s"
    songs = search(song_name,{:singer_name=>song_name})
    song_list = get_input_again songs
  else
    song_list = index.split(",").map {|song_list| song_list.to_i }
  end    

  if songs.length == 0 
    exit
  end

  if song_list.length > 0
    song_list.each_with_index do |index, count|
      puts "Downloading (#{count} of #{song_list.length}) Item #{index} "
      selected_song = songs[index-1]
      song_id       = selected_song[:id]
      song_name     = selected_song[:name]
      
      song_downloader = SongDownloader.new(selected_song)
      song_downloader.download
    end
  end
end