class Membership
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :remote_ids, type: Array, default: []
  embedded_in :user
end