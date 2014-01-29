class Remote
  include Mongoid::Document
  field :video_id, type: String
  field :provider, type: String
  field :title, type: String
  field :description, type: String
  field :duration, type: Integer
  field :thumbnail_small, type: String
  field :thumbnail_medium, type: String
  field :thumbnail_large, type: String
  field :embed_url, type: String
  field :embed_code, type: String
  field :date, type: DateTime
  field :status, type: String, default: "stopped"
  field :start_at, type: Integer, default: 0
  validates_presence_of :video_id
  validates_presence_of :provider
  validates_presence_of :status
  validates_presence_of :duration
  validates_presence_of :start_at
end
