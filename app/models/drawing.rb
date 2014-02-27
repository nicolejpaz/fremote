class Drawing
  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  field :coordinates, type: Array, default: []
  embedded_in :remote

  def save_to_database(coordinates)
    new_drawing_coordinates = self.coordinates
    coordinates.each do |coordinate|
      new_drawing_coordinates << coordinate[1]
    end

    self.coordinates = new_drawing_coordinates
    self.save
  end
end