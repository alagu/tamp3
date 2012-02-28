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
      
      pp zero_results
      
      if zero_results
        raise "No results found for #{@query}"
      end
      song_hash = {:name => song.children[2].text,
                   :singers => song.children[2].text,
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

  def fetch_page
    url = "http://thiraipaadal.com/search.php?txtselected=&lang=en&schMovieName=&schSongName=#{@song_term}&schSinger=&schLyrics=No&sbt=++Search++"
    
    page = @agent.get(url)
    return page
  end
end

