require 'spec_helper'
require 'faker'

describe DrawingsController do
  before(:each) do
    @sample_user = create(:user)
    @another_user = create(:user, name: Faker::Internet.user_name.slice(1..16), email: Faker::Internet.email)
    
    @params = attributes_for(:remote)

    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @sample_owned_remote = Remote.make(@sample_user)
    VCR.use_cassette('remote') do
      @sample_owned_remote.populate(@params[:url])
    end
    @sample_owned_remote.save

    @sample_coordinates = []
    10.times do |number|
      @sample_coordinates << {x_coordinate: number, y_coordinate: number, color: 'FF0000'}
    end
  end

  describe 'POST write' do
    context 'when given coordinates' do
      before(:each) do
        controller.stub(:current_user){@sample_user}
        post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
        @drawing_response = response.dup
        response.close
      end
      
      it 'retrieves @remote from remote_id' do
        expect(assigns(:remote)).to eq (@sample_remote)
      end

      it 'gets the current user if there is one' do
        expect(assigns(:user)).to eq(@sample_user)
      end

      it 'returns an OK response' do
        expect(@drawing_response.status).to eq 200
      end

      it 'returns a response that contains the correct color' do
        expect(@drawing_response.as_json.to_s).to include 'FF0000'
      end
    end

    context 'when there are no coordinates' do
      before(:each) do
        post :write, id: @sample_remote.remote_id, coordinates: []
        @drawing_response = response.dup
        response.close
      end

      it 'renders nothing' do
        expect(@drawing_response.as_json.to_s).to_not include 'FF0000'
      end
    end
  end

  describe 'GET read' do
    before(:each) do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      get :read, id: @sample_remote.remote_id
      
      @read_response = response.dup
      response.close
    end

    it 'receives an OK response' do
      expect(@read_response.status).to eq 200
    end

    it 'retrieves the coordinates on load' do
      expect(@read_response.as_json.to_s).to include 'FF0000'
    end
  end

  describe "POST update" do
    it "retrieves @remote from remote_id" do
      post :update, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets the current user if there is one" do
      controller.stub(:current_user){@sample_user}
      post :update, id: @sample_remote.remote_id
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "receives and dispatches drawing coordinates notification" do
      controller.stub(:current_user){@sample_user}
      coords = nil
      ActiveSupport::Notifications.subscribe("drawing:#{@sample_remote.remote_id}") do |name, start, finish, id, payload|
          coords = payload
      end
      post :update, id: @sample_remote.remote_id, coordinates: "dummy coords"
      until coords != nil do
      end
      ActiveSupport::Notifications.unsubscribe("drawing:#{@sample_remote.remote_id}")
      expect(JSON.parse(coords)["coordinates"]).to eq("dummy coords")
    end

    it 'returns an OK response' do
      post :update, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      @drawing_response = response.dup
      response.close
      expect(@drawing_response.status).to eq 200
    end

    it 'returns a response that includes the selected color' do
      post :update, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      @drawing_response = response.dup
      response.close
      expect(@drawing_response.as_json.to_s).to include 'FF0000'
    end
  end

  describe 'POST clear' do
    context 'when the user is authorized to use the canvas' do
      before(:each) do
        post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
        post :clear, id: @sample_remote.remote_id
        @clear_response = response.dup
        response.close
      end

      it 'returns an OK response' do
        expect(@clear_response.status).to eq 200
      end

      it 'sets drawing coordinates to an empty array' do
        expect(Remote.last.drawing.coordinates.length).to eq 0
      end
    end

    context 'when the user is not authorized to use the canvas' do
      before(:each) do
        sign_in @another_user

        post :write, id: @sample_owned_remote.remote_id, coordinates: @sample_coordinates
        post :clear, id: @sample_remote.remote_id
        @clear_response = response.dup
        response.close
      end

      it 'does not clear the canvas' do
        expect(Remote.last.drawing.coordinates.length).to eq 10
      end
    end
  end
end