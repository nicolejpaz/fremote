class Playlist
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :list, type: Array, default: []
  field :selection, type: Integer, default: 0
  embedded_in :remote
end
