class MemberList
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :members, type: Array, default: []
  embedded_in :remote
end