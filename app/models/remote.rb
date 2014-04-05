class Remote
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  include RemotesHelper
  after_initialize :spawn_embeds, :generate_remote_id
  field :remote_id, type: String
  field :name, type: String, default: "Unnamed Remote"
  field :description, type: String, default: "No description."
  field :url, type: String
  field :status, type: Integer, default: -1
  field :start_at, type: Integer, default: 0
  field :admin_only, type: Boolean, default: false
  field :watchers, type: Array, default: []
  field :last_controlled_at, type: DateTime, default: Time.now.utc
  index({ remote_id: 1 }, { unique: true, name: "remote_id_index" })
  belongs_to :user, index: true
  embeds_one :playlist
  index "playlist._id" => 1
  embeds_one :drawing
  index "drawing._id" => 1
  embeds_one :authorization
  index "authorization._id" => 1
  embeds_one :member_list
  index "member_list._id" => 1
  validates_presence_of :status
  validates_presence_of :start_at
  validates_length_of :description, maximum: 5000
  validates_length_of :name, maximum: 60

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

    delete_members(params) if params[:delete]

    if params[:member]
      check_if_members(params)
      self.authorization.update_permissions(params)
    end

    self.save
  end

  def populate_with_options(params, user = nil)
    self.name = params[:name] unless params[:name] == '' || params[:name] == nil
    self.description = params[:description] unless params[:description] == '' || params[:description] == nil
    self.admin_only = to_boolean(params[:admin_only]) || false
    check_if_members(params)
    self.save
    return { message: "Congratulations!  Take control of your remote.", status: :notice, path: remote_path(self.remote_id) }
  end

  def control(params, remote_owner = nil)
    if self.admin_only == false || remote_owner

      self.status = params["status"] if params["status"]
      self.start_at = params["start_at"].to_i if params["start_at"]
      self.last_controlled_at = Time.now.utc
      if remote_owner == self.user && params.has_key?("remote") && params["remote"].has_key?("admin_only")
        self.admin_only = to_boolean(params["remote"]["admin_only"])
      end

      check_if_selection(params)
    end
  end

  def skip
    unless (self.playlist.playing + 1) > (self.playlist.list.count - 1)
      self.playlist.playing += 1 if self.playlist.playing
      self.playlist.selection += 1
      self.status = 1
    end
    self.start_at = 0
    self.playlist.votes = 0
    self.playlist.save
    self.save
    Notify.new("playlist_block:#{self.remote_id}", {"block" => true}.to_json)
    Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.playlist.list[self.playlist.playing]["url"])) })
    Notify.new("playlist_play:#{self.remote_id}", 'playing' => self.playlist.playing)
    Notify.new("playlist_block:#{self.remote_id}", {"block" => false}.to_json)
  end

  def kind_of_user(user = nil)
    if user
      determine_user_type(user)
    else
      return 'guest'
    end
  end

  private
  def spawn_embeds
    self.playlist = Playlist.new if self.playlist == nil
    self.drawing = Drawing.new if self.drawing == nil
    self.authorization = Authorization.new if self.authorization == nil 
    self.member_list = MemberList.new if self.member_list == nil
  end

  def generate_remote_id
    self.remote_id = Digest::MD5.hexdigest(DateTime.now.to_s + DateTime.now.nsec.to_s).slice(0..9) if self.remote_id == nil
  end

  def push_link_to_playlist(url)
    new_media = Media.new(url)
    if new_media != nil
      self.playlist.list << new_media
      self.save
      return { message: "Congratulations!  Take control of your remote.", status: :notice, path: remote_path(self.remote_id) }
    else
      return { message: "The video URL you provided is invalid.  Try again using a valid YouTube, Vimeo, Veoh, Blip, or Soundcloud URL.", status: :alert, path: root_path }
    end
  end

  def check_if_selection(params)
    if params["playing"]
      self.playlist.playing = params["playing"].to_i
      self.playlist.save
      self.start_at = 0
      self.status = 1
      self.save
      Notify.new("playlist_play:#{self.remote_id}", {'playing' => self.playlist.playing})
      Notify.new("playlist_block:#{self.remote_id}", {"block" => false}.to_json)
    end

    if params.has_key?("selection")
      change_playlist_selection(params)
    elsif params["status"] == 0 || params["status"] == "0"
      change_status_if_zero(params)
    else
      self.save
      Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.last_controlled_at, 'dispatched_at' => Time.now })
      Notify.new("playlist_play:#{self.remote_id}", 'playing' => self.playlist.playing)
    end
  end

  def change_playlist_selection(params)
    Notify.new("playlist_block:#{self.remote_id}", {"block" => true, "add" => true}.to_json)
    self.playlist.selection = params["selection"].to_i
    self.start_at = 0
    self.status = 1
    self.save
    Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.playlist.list[self.playlist.selection]["url"])) })
    Notify.new("playlist_play:#{self.remote_id}", 'playing' => self.playlist.playing)
    Notify.new("playlist_block:#{self.remote_id}", {"block" => false}.to_json)
  end

  def change_status_if_zero(params)
    unless ((self.playlist.selection + 1) > (self.playlist.list.count - 1))
      self.playlist.selection = (self.playlist.selection + 1)
      self.status = 1
      self.playlist.playing += 1
    end
    self.start_at = 0
    self.playlist.votes = 0
    self.playlist.save
    self.save
    Notify.new("control:#{self.remote_id}", {'start_at' => self.start_at, 'status' => self.status, 'updated_at' => self.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.playlist.list[self.playlist.selection]["url"])) })
    Notify.new("playlist_play:#{self.remote_id}", 'playing' => self.playlist.playing)
  end

  def check_if_members(params)
    if params[:member] != [''] && params[:member]
      params[:member].each do |member|
        check_if_member_exists(member)
      end
    end
  end

  def check_if_member_exists(member)
    new_member = User.find_by({name: member})
    if new_member
      self.member_list.members << new_member.id
      new_member.add_to_membership(self)
    end
  end

  def delete_members(params)
    params[:delete].each do |delete_name|
      member = User.find_by({name: delete_name})
      self.member_list.members.delete(member.id)
      member.delete_remote_from_user_memberships(self)
    end
  end

  def determine_user_type(user)
    if self.member_list.members.include? user.id
      return 'member'
    elsif self.user && self.user.id == user.id
      return 'owner'
    else
      return 'user'
    end
  end
end
