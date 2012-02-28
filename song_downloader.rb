require 'rubygems'
require 'mechanize'
require 'xmlsimple'
require 'uri'
require 'net/http'

class SongDownloader
  def initialize(song_id, song_name)
    @song_id = song_id
    @song_name = song_name
    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end
  
  def get_playlist_id (player_content)
    script    = player_content.search('//script')[2]
    xml_line  = script.text.split("\n")[2]
    playlist_id    = xml_line.split('"')[3]
  end
  
  def get_song_path (playlist_id)
    xml_url  = "http://thiraipaadal.com/plists/#{playlist_id}.xml?767"
    response = @agent.get(xml_url)
    xml      = XmlSimple.xml_in response.body.gsub('&', ' ')
    return xml["trackList"][0]["track"].first["location"].first
  end
  
  def download_url (song_path)
    song_name = song_path.split(' -- ')[1] + '.mp3'
    song_name = URI.escape song_name
    folder_name = song_path.split(' - ')[0]
    
    "http://thiraipaadal.com/tempdownloads/084097109105108/7779867369657666857783/#{folder_name}/#{song_name}"
  end
  
  def download_player_page
    player_url = "http://thiraipaadal.com/tpplayer.asp?sngs='#{@song_id}'&lang=en"
    @agent.get(player_url)
  end
  
  def fetch_mp3 (url)
    Thread.new do
      thread = Thread.current
      body = thread[:body] = []
    
      url = URI.parse url
      Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
        length = thread[:length] = response['Content-Length'].to_i
    
        File.open @song_name + '.mp3', 'w' do |io|          
          response.read_body do |fragment|
            io.write << fragment
            thread[:done] = (thread[:done] || 0) + fragment.length
            thread[:progress] = thread[:done].quo(length) * 100
          end
        end
      end
    end
  end
  
  def download
    playlist_id = get_playlist_id(download_player_page)
    
    puts " "
    puts "Got xml id (#{playlist_id})"    
    song_path = get_song_path(playlist_id)

    download_link =  download_url(song_path)
    puts "Got song download link #{download_link}"
    
    thread = fetch_mp3(download_link)
    puts "%.2f%%" % thread[:progress].to_f until thread.join 1
    
  end
end