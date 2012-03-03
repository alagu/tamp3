require 'rubygems'
require 'mechanize'
require 'xmlsimple'
require 'uri'
require 'net/http'
require 'yaml'
require 'progressbar'

class SongDownloader
  def initialize(song)
    @song_id    = song[:id]
    @song_name  = song[:name]
    @movie_name = song[:movie]
    @movie_id   = song[:movie_id]
    @composer   = ''
    @file_path  = ''

    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    @base_path = load_base_path
  end

  def load_base_path
    if File.exists? (ENV['HOME']+'/.tamp3rc') 
      conf = YAML.load_file(ENV['HOME']+ '/.tamp3rc')
      return conf['base_path']
    else
      return '.'
    end
  end
  
  def get_playlist_id (player_content)
    script      = player_content.search('//script')[2]
    xml_line    = script.text.split("\n")[2]
    playlist_id = xml_line.split('"')[3]
  end
  
  def get_song_path (playlist_id)
    xml_url  = "http://thiraipaadal.com/plists/#{playlist_id}.xml?767"
    response = @agent.get(xml_url)
    xml      = XmlSimple.xml_in response.body.gsub('&', ' ')
    return xml["trackList"][0]["track"].first["location"].first
  end
  
  def download_url (song_path)
    song_name   = song_path.split(' -- ')[1] + '.mp3'
    song_name   = URI.escape song_name
    folder_name = song_path.split(' - ')[0]
    
    "http://thiraipaadal.com/tempdownloads/084097109105108/7779867369657666857783/#{folder_name}/#{song_name}"
  end
  
  def get_album_composer
    url = "http://thiraipaadal.com/album.php?ALBID=#{@movie_id}&lang=en"
    response = @agent.get(url)
    response.links.each do |link|
      if not link.href.index('md.php?MDID=').nil?
        @composer = link.text
      end
    end
    
    puts "Got album composer - #{@composer}"
    return @composer
  end  
  
  
  def download_player_page
    player_url = "http://thiraipaadal.com/tpplayer.asp?sngs='#{@song_id}'&lang=en"
    @agent.get(player_url)
  end
  
  def create_directory
    path = "#{@base_path}/#{@composer}/#{@movie_name}/"
    FileUtils.mkdir_p(path)
    
    path
  end
  
  def fetch_mp3 (url)
    get_album_composer
    path      = create_directory
    @file_path = path + @song_name + '.mp3'
    puts "Downloading to \"#{@file_path}\""
    
    Thread.new do
      thread = Thread.current
      body = thread[:body] = []
    
      url = URI.parse url
      Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
        length = thread[:length] = response['Content-Length'].to_i
        

        File.open (@file_path), 'w' do |io|          
          response.read_body do |fragment|
            io.write fragment
            thread[:done] = (thread[:done] || 0) + fragment.length
            thread[:progress] = thread[:done].quo(length) * 100
          end
        end
      end
    end
  end
  
  
  def is_mac?
    RUBY_PLATFORM.downcase.include?("darwin")
  end
  
  def play_the_song
    if is_mac?
      print "Should i play it? (Y/N)"
      should_i_play = STDIN.gets 
      if should_i_play.chomp == 'Y'
        puts "Playing #{@file_path}"        
        system('open "' + @file_path + '"')
      end
    end
  end
  
  def download
    playlist_id = get_playlist_id(download_player_page)
    
    puts " "
    puts "Got xml id"    
    song_path = get_song_path(playlist_id)

    download_link =  download_url(song_path)
    puts "Got song download link. Starting download \n\n"
    
    thread = fetch_mp3(download_link)
    i = 0
    
    progress          = ProgressBar.new("  Downloaded", 100)
    progress.bar_mark = '*'
    
    until thread.join 1
      progress.set thread[:progress].to_i
    end
    progress.finish
    
    puts "\n -------- \n"
    puts "#{@song_name} downloaded."
    
    play_the_song
  end
end
