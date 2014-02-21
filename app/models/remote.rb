class Remote
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :remote_id, type: String
  field :url, type: String
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  belongs_to :user
  validates_presence_of :status
  validates_presence_of :start_at

  def to_param
    remote_id
  end

  def populate(url)
    unless url == ""
      if url[/(youtube.com|vimeo.com)/] != nil
        self.url = url
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
      self.save
      ActiveSupport::Notifications.instrument("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'sender_id' => params['sender_id'] }.to_json)
    end
  end


end
