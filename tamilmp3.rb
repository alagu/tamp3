require 'rubygems'
require 'mechanize'
require 'pp'

@agent = Mechanize.new


class SongDownload
  def initialize(song_term)
    @song_term = song_term
    @agent = Mechanize.new
  end
  
  def fetch_tables
    page = fetch_page
    rowA = page.search("//tr[@class='rowA']")
    rowB = page.search("//tr[@class='rowB']")
    
    rowA + rowB
  end

  def fetch_page
    url = "http://thiraipaadal.com/search.php?txtselected=&lang=en&schMovieName=&schSongName=#{@song_term}&schSinger=&schLyrics=No&sbt=++Search++"
    
    page = @agent.get(url)
    return page
  end
end

