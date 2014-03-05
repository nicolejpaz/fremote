class Remote
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  include RemotesHelper
  after_initialize :spawn_embeds
  field :remote_id, type: String
  field :name, type: String, default: "Unnamed Remote"
  field :description, type: String, default: "No description."
  field :url, type: String
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  field :watchers, type: Array, default: []
  belongs_to :user
  embeds_one :playlist
  embeds_one :drawing
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
    unless url == ""
      push_link_to_playlist(url)
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

  def update(params)
    if params[:name] != nil && params[:name] != ''
      self.name = params[:name]
    end

    if params[:description] != nil && params[:description] != ''
      self.description = params[:description]
    end

    self.save
  end

  def control(params, remote_owner = nil)
    if self.admin_only == false || remote_owner

      self.status = params["status"] if params["status"]
      self.start_at = params["start_at"].to_i if params["start_at"]
      if remote_owner == self.user && params.has_key?("remote") && params["remote"].has_key?("admin_only")
        self.admin_only = to_boolean(params["remote"]["admin_only"])
      end

      check_if_params_has_selection(params)
    end
  end

  def kind_of_user(user = nil)
    return "guest" if user == nil

    if user == self.user
      return "owner"
    else
      return "user"
    end

  end

  private
  def spawn_embeds
    self.playlist = Playlist.new if self.playlist == nil
    self.drawing = Drawing.new if self.drawing == nil
  end

  def push_link_to_playlist(url)
    new_media = Media.new(url)
    if new_media != nil
      self.playlist.list << new_media
      self.remote_id = Digest::MD5.hexdigest(url + DateTime.now.to_s + DateTime.now.nsec.to_s).slice(0..9)
      self.save
      return { message: "Congratulations!  Take control of your remote.", status: :notice, path: remote_path(self.remote_id)}
    else
      return { message: "Invalid URL", status: :alert, path: root_path }
    end
  end

  def check_if_params_has_selection(params)
    if params.has_key?("selection")
      change_playlist_selection_if_selection_key_exists(params)
    elsif params["status"] == 0 || params["status"] == "0"
      change_status_if_status_is_zero(params)
    else
      self.save
      Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now })
    end
  end

  def change_playlist_selection_if_selection_key_exists(params)
    self.playlist.selection = params["selection"].to_i
    self.start_at = 0
    self.status = 1
    self.save
    Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.playlist.list[self.playlist.selection]["url"])) })
  end

  def change_status_if_status_is_zero(params)
    self.playlist.selection = (self.playlist.selection + 1) unless ((self.playlist.selection + 1) > (self.playlist.list.count - 1))
    self.start_at = 0
    self.status = 1
    self.save
    Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.playlist.list[self.playlist.selection]["url"]))  })
  end

end
