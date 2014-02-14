class Remote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :video_id, type: String
  field :remote_id, type: String
  field :provider, type: String
  field :title, type: String
  field :description, type: String
  field :duration, type: Integer
  field :thumbnail_small, type: String
  field :thumbnail_medium, type: String
  field :thumbnail_large, type: String
  field :url, type: String
  field :embed_url, type: String
  field :embed_code, type: String
  field :date, type: DateTime
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  belongs_to :user
  validates_presence_of :video_id
  validates_presence_of :provider
  validates_presence_of :status
  validates_presence_of :duration
  validates_presence_of :start_at

  def to_param
    remote_id
  end

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
        self.url = video.url
        self.embed_url = video.embed_url
        self.embed_code = video.embed_code
        self.date = video.date
        self.remote_id = Digest::MD5.hexdigest(video_id + DateTime.now.to_s + DateTime.now.nsec.to_s).slice(0..9)
        return { message: "Congratulations!  Use the controls below the video to remote control it.", status: :success }
      rescue
        return { message: "Invalid URL", status: :danger }
      end
    else
      return { message: "URL can't be blank", status: :danger }
    end
  end

end
