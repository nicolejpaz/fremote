class Drawing
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :coordinates, type: Array, default: []
  embedded_in :remote
end