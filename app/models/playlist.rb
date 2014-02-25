class Playlist
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :list, type: Array, default: []
  field :selection, type: Integer, default: 0
  embedded_in :remote

  def sort_list_item(old_position, new_position, user = nil)
    list = self.list.dup
    element = list[old_position].dup
    list.delete_at(old_position)
    list.insert(new_position, element)
    self.list = list
    self.save
    self.remote.save
    ActiveSupport::Notifications.instrument("playlist_sort:#{self.remote.remote_id}", {'playlist' => self.list }.to_json)
  end

end
