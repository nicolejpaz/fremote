class Remote
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :remote_id, type: String
  field :url, type: String
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  field :playlist, type: Array, default: []
  field :selection, type: Integer, default: 0
  belongs_to :user
  validates_presence_of :status
  validates_presence_of :start_at

  def to_param
    remote_id
  end

  def populate(url)
    new_video = {}
    unless url == ""
      if url[/(youtube.com|vimeo.com)/] != nil
        new_video["url"] = url
        new_video["title"] = ViddlRb.get_names(url).first
        self.playlist << new_video
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
        self.selection = params["selection"].to_i
        self.start_at = 0
        self.status = 1
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'], 'stream_url' => URI::encode(ViddlRb.get_urls(self.playlist[self.selection]["url"]).first) }.to_json)
      elsif params["status"] == 0 || params["status"] == "0"
        self.selection = (self.selection + 1) unless ((self.selection + 1) > (self.playlist.count - 1))
        self.start_at = 0
        self.status = 1
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'], 'stream_url' => URI::encode(ViddlRb.get_urls(self.playlist[self.selection]["url"]).first)  }.to_json)
      else
        self.save
        ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id']}.to_json)
      end


    end
  end


end
