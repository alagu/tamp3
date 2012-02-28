require 'rubygems'
require 'mechanize'
require 'xmlsimple'
  
class XmlParser < Mechanize::File
  attr_reader :xml
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @xml = Nokogiri::XML(body)
    super uri, response, body, code
  end
end

class SongDownloader
  def initialize(song_id)
    @song_id = song_id
    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end
  
  def get_xml_id (player_content)
    script    = player_content.search('//script')[2]
    xml_line  = script.text.split("\n")[2]
    xml_id    = xml_line.split('"')[3]
  end
  
  def download_xml (xml_id)
    xml_url  = "http://thiraipaadal.com/plists/#{xml_id}.xml?767"
    response = @agent.get(xml_url)
    xml      = XmlSimple.xml_in response.body.gsub('&', ' ')
    return xml["trackList"][0]["track"].first["location"].first
  end
  
  def download_player_page
    player_url = "http://thiraipaadal.com/tpplayer.asp?sngs='#{@song_id}'&lang=en"
    @agent.get(player_url)
  end
  
  def download
    xml_id = get_xml_id(download_player_page)
    
    puts "Got xml id #{xml_id}"
    
    download_xml(xml_id)
  end
end