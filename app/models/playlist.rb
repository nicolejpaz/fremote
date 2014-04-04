class Playlist
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  include RemotesHelper
  field :list, type: Array, default: []
  field :selection, type: Integer, default: 0
  field :playing, type: Integer
  field :votes, type: Integer, default: 0
  embedded_in :remote

  def sort_list_item(old_position, new_position, user = nil)
    list = self.list.dup
    element = list[old_position].dup
    list.delete_at(old_position)
    list.insert(new_position, element)
    self.list = list
    self.playing = new_position
    if is_authorized?(self.remote, user)
      self.save
      ActiveSupport::Notifications.instrument("playlist_sort:#{self.remote.remote_id}", {'playlist' => self.list }.to_json)
      Notify.new("playlist_play:#{self.remote.remote_id}", {"playing" => self.playing})
    end
  end

  def add_list_item(new_media, user = nil)
    self.list << new_media unless new_media == nil
    if is_authorized?(self.remote, user)
      self.save; self.remote.save
      Notify.new("playlist_add:#{self.remote.remote_id}", new_media.to_json)
    end
  end

  def delete(params)
    Notify.new("playlist_block:#{self.remote.remote_id}", {"block" => true}.to_json)
    if params[:clear]
      self.delete_all
    else
      self.delete_list_item(params[:index])
    end
    Notify.new("playlist_block:#{self.remote.remote_id}", {"block" => false}.to_json)
  end

  def delete_list_item(index, user = nil)
    self.list.delete_at(index.to_i)
    if index.to_i == self.selection  
      self.selection = (self.selection + 1) unless ((self.selection + 1) > (self.list.count - 1))
      self.remote.start_at = 0
      self.remote.status = 1
      self.save
      self.remote.save
      if self.list[self.selection]
        Notify.new("control:#{self.remote.remote_id}", {'start_at' => self.remote.start_at, 'status' => self.remote.status, 'updated_at' => self.remote.updated_at, 'dispatched_at' => Time.now, 'stream_url' => URI::encode(Media.link(self.list[self.selection]["url"])) })
        Notify.new("playlist_play:#{self.remote.remote_id}", 'playing' => self.playing)
      end
    end
    self.remote.save
    self.save
    Notify.new("playlist_delete:#{self.remote.remote_id}", {'index' => index}.to_json)
  end

  def delete_all
    self.list = []
    self.save
    self.remote.save
    Notify.new("playlist_clear:#{self.remote.remote_id}")
  end
end
