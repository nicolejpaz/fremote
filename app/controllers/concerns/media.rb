module Media
  def self.new(url = nil)
    if url[/(youtube.com|vimeo.com)/] != nil
      new_media = {}
      new_media["url"] = url
      new_media["title"] = ViddlRb.get_names(url).first
    end
    return new_media
  end
end