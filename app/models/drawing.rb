class Drawing
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :coordinates, type: Array, default: []
  embedded_in :remote

  def save_to_database(coordinates)
    coordinates.each do |coordinate|
      self.coordinates << coordinate[1]
    end
    self.save
  end
end