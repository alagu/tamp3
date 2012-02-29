class SongSearcher
  def initialize(song_term)
    @song_term = song_term
    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end
  
  def parse_songs (songs)
    songs_parsed = []
    songs.each do |song|
      zero_results = (song.text.index('zero results'))
      
      if not zero_results.nil?
        return []
      end
      
      song_hash = {:movie => song.children[1].text,
                   :movie_id => (song.children[1].children[0][:href].match %r|=(.*)&|)[1],
                   :name => song.children[2].text,
                   :singers => song.children[3].text,
                   :id => song.children[0].children[0][:value]
                   }
      songs_parsed.push song_hash
    end
    
    songs_parsed
  end
  
  def song_xpather(page)
    rowA = page.search("//tr[@class='rowA']")
    rowB = page.search("//tr[@class='rowB']")
    
    parse_songs (rowA[1..rowA.length] + rowB[1..rowB.length])
  end
  
  def search_and_print_songs
    songs = search_songs + search_movies
    
    if songs.empty?
      puts "No such songs/movies found"
    end
    
    songs.each_with_index do |song,index|
      puts "#{index+1}. #{song[:name]}"
      puts "   Movie: #{song[:movie]}"
      puts "   Singers: #{song[:singers]}"
      puts " "
    end
    
    return songs
  end
  
  def search_movies
    url = "http://thiraipaadal.com/search.php?txtselected=&lang=en&schMovieName=#{@song_term}&schSongName=&schSinger=&schLyrics=No&sbt=++Search++"
    
    page = @agent.get(url)
    return song_xpather(page)
  end

  def search_songs
    url = "http://thiraipaadal.com/search.php?txtselected=&lang=en&schMovieName=&schSongName=#{@song_term}&schSinger=&schLyrics=No&sbt=++Search++"
    
    page = @agent.get(url)
    return song_xpather(page)
  end
  
end

