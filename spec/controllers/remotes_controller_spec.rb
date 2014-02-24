require 'spec_helper'

describe RemotesController do
  describe 'POST drawing' do
    before(:each) do
      @sample_remote = Remote.make
      @sample_remote.populate('http://www.youtube.com/watch?v=4tzhyfWHdLo')
      @sample_remote.save

      @sample_coordinates = []
      10.times do |number|
        @sample_coordinates << {x_coordinate: number, y_coordinate: number, color: 'FF0000'}
      end
    end

    it 'returns a response that includes the selected color' do
      post :drawing, id: @sample_remote.remote_id, coordinates: @sample_coordinates

      drawing_response = response.dup
      response.close

      expect(drawing_response.as_json.to_s).to include 'FF0000'
    end
  end
end
