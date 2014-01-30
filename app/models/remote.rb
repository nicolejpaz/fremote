class Remote
  include Mongoid::Document
  field :video_id, type: String
  field :remote_id, type: String
  field :provider, type: String
  field :title, type: String
  field :description, type: String
  field :duration, type: Integer
  field :thumbnail_small, type: String
  field :thumbnail_medium, type: String
  field :thumbnail_large, type: String
  field :embed_url, type: String
  field :embed_code, type: String
  field :date, type: DateTime
  field :status, type: String, default: "stopped"
  field :start_at, type: Integer, default: 0
  validates_presence_of :video_id
  validates_presence_of :provider
  validates_presence_of :status
  validates_presence_of :duration
  validates_presence_of :start_at

  def populate(url)
    unless url == ""

      begin
        video = VideoInfo.new(url)
        self.video_id = video.video_id
        self.provider = video.provider
        self.title = video.title
        self.description = video.description
        self.duration = video.duration
        self.thumbnail_small = video.thumbnail_small
        self.thumbnail_medium = video.thumbnail_medium
        self.thumbnail_large = video.thumbnail_large
        self.embed_url = video.embed_url
        self.embed_code = video.embed_code
        self.date = video.date
        self.remote_id = Digest::MD5.hexdigest(video_id + DateTime.now.to_s + DateTime.now.nsec.to_s).slice(0..9)
        return { message: "Congratulations!", status: :success }
      rescue
        return { message: "Invalid URL", status: :danger }
      end
    else
      return { message: "URL can't be blank", status: :danger }
    end
  end

end
