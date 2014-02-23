class Remote
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  after_initialize :spawn_playlist
  field :remote_id, type: String
  field :url, type: String
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  belongs_to :user
  embeds_one :playlist
  validates_presence_of :status
  validates_presence_of :start_at

  def to_param
    remote_id
  end

  def json
    json_object = {}
    json_object["remote_id"] = self.remote_id
    json_object["url"] = self.url
    list = []
    self.playlist.list.each do |element|
      list << element
    end
    json_object["playlist"] = { "list" => list, "selection" => self.playlist.selection }
    json_object.to_json
  end

  def populate(url)
    new_video = {}
    unless url == ""
      if url[/(youtube.com|vimeo.com)/] != nil
        new_video["url"] = url
        new_video["title"] = ViddlRb.get_names(url).first
        self.playlist.list << new_video
        self.remote_id = Digest::MD5.hexdigest(url + DateTime.now.to_s + DateTime.now.nsec.to_s).slice(0..9)
        return { message: "Congratulations!  Take control of your remote.", status: :notice, path: remote_path(self.remote_id)}
      else
        return { message: "Invalid URL", status: :alert, path: root_path }
      end
    else
      return { message: "URL can't be blank", status: :alert, path: root_path }
    end
  end

  def self.make(user = nil)
    if user
      return user.remotes.new
    else
      return self.new
    end
  end

  def update(params, remote_owner = nil)
    if self.admin_only == false || remote_owner

      self.status = params["status"] if params["status"]
      self.start_at = params["start_at"].to_i if params["start_at"]
      self.admin_only = to_boolean(params["remote"]["admin_only"]) if params.has_key?("remote") && params["remote"].has_key?("admin_only")

      if params.has_key?("selection")
        self.playlist.selection = params["selection"].to_i
        self.start_at = 0
        self.status = 1
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'], 'stream_url' => URI::encode(ViddlRb.get_urls(self.playlist.list[self.playlist.selection]["url"]).first) }.to_json)
      elsif params["status"] == 0 || params["status"] == "0"
        self.playlist.selection = (self.playlist.selection + 1) unless ((self.playlist.selection + 1) > (self.playlist.count - 1))
        self.start_at = 0
        self.status = 1
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'], 'stream_url' => URI::encode(ViddlRb.get_urls(self.playlist.list[self.playlist.selection]["url"]).first)  }.to_json)
      else
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id']}.to_json)
      end


    end
  end

  private
  def spawn_playlist
    self.playlist = Playlist.new if self.playlist == nil
  end

end
