module Media
  require 'net/http'
  require 'uri'

  def self.new(url = nil)
    if self.is_viddl?(url)
      new_media = {}
      new_media["url"] = url
      new_media["title"] = ViddlRb.get_names(url).first
    elsif self.is_other?(url)
      new_media = {}
      new_media["url"] = url
      new_media["title"] = url
    elsif self.is_direct?(url)
      new_media = {}
      new_media["url"] = url
      new_media["title"] = url
    end
    return new_media
  end

  def self.link(url = nil)
    if self.is_viddl?(url)
      ViddlRb.get_urls(url).first
    elsif self.is_other?(url)
      self.get_other_video_link(url)
    elsif self.is_direct?(url)  
      url
    end
  end

  def self.get_other_video_link(url)
    if url.include?("videoweed.es")
      uri = URI(url)
      weed_page = Net::HTTP.get(uri)
      file_code = /(file=\")(.*?)(\";)/.match(weed_page)[2]
      file_key = /(filekey=\")(.*?)(\";)/.match(weed_page)[2]
      api_url = "http://www.videoweed.es/api/player.api.php?user=undefined&codes=1&file=#{file_code}&pass=undefined&key=#{file_key}"
      api_uri = URI(api_url)
      api_data = Net::HTTP.get(api_uri)
      stream_link = /(url=)(.*?)(&title=)/.match(api_data)[2]
      return stream_link
    end
  end

  def self.is_viddl?(url)
    url.include?("youtube.com") || url.include?("youtu.be") || url.include?("vimeo.com") || url.include?("veoh.com") || url.include?("soundcloud.com") || url.include?("blip.tv") 
  end

  def self.is_other?(url)
    url.include?("videoweed.es")
  end

  def self.is_direct?(url)
    url.include?(".webm") || url.include?(".mp4") || url.include?(".flv") || url.include?(".mp3")
  end

end