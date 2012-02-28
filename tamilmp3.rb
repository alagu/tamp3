require 'rubygems'
require 'mechanize'
require 'pp'

@agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


class SongDownload
  def initialize(song_term)
    @song_term = song_term
    @agent = Mechanize.new
  end
  
  def parse_songs (songs)
    songs_parsed = []
    songs.each do |song|
      zero_results = (song.text.index('zero results'))
      
      if not zero_results.nil?
        return []
      end
      
      song_hash = {:movie => song.children[1].text,
                   :name => song.children[2].text,
                   :singers => song.children[3].text,
                   :id => song.children[0].children[0][:value]
                   }
      songs_parsed.push song_hash
    end
    
    songs_parsed
  end
  
  def search_songs
    page = fetch_page
    rowA = page.search("//tr[@class='rowA']")
    rowB = page.search("//tr[@class='rowB']")
    
    parse_songs (rowA[1..rowA.length] + rowB[1..rowB.length])
  end
  
  def search_and_print_songs
    songs = search_songs
    songs.each_with_index do |song,index|
      puts "#{index+1}. #{song[:name]}"
      puts "   Movie: #{song[:movie]}"
      puts "   Singers: #{song[:singers]}"
      puts " "
    end
    
    return songs
  end

  def fetch_page
    url = "http://thiraipaadal.com/search.php?txtselected=&lang=en&schMovieName=&schSongName=#{@song_term}&schSinger=&schLyrics=No&sbt=++Search++"
    
    puts "Hitting #{url}"
    
    page = @agent.get(url)
    return page
  end
  
end

