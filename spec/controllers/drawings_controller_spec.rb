require 'spec_helper'

describe DrawingsController do
  before(:each) do
    @sample_user = User.create name: "john", email: "john@john.com", password: "password"
    @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
    @sample_remote = Remote.make
    @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
    @sample_remote.save

    @sample_coordinates = []
    10.times do |number|
      @sample_coordinates << {x_coordinate: number, y_coordinate: number, color: 'FF0000'}
    end
  end

  describe 'POST write' do
    it 'retrieves @remote from remote_id' do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      expect(assigns(:remote)).to eq (@sample_remote)
    end

    it 'gets the current user if there is one' do
      controller.stub(:current_user){@sample_user}
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      expect(assigns(:user)).to eq(@sample_user)
    end

    it 'returns an OK response' do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      @drawing_response = response.dup
      response.close
      expect(@drawing_response.status).to eq 200
    end

    it 'returns a response that contains the correct color' do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      @drawing_response = response.dup
      response.close
      expect(@drawing_response.as_json.to_s).to include 'FF0000'
    end
  end

  describe 'GET read' do
    it 'receives an OK response' do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      get :read, id: @sample_remote.remote_id
      
      @read_response = response.dup
      response.close
      expect(@read_response.status).to eq 200
    end

    it 'retrieves the coordinates on load' do
      post :write, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      response.close

      get :read, id: @sample_remote.remote_id
      @read_response = response.dup
      response.close
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
    it 'returns an OK response' do
      post :clear, id: @sample_remote.remote_id
      clear_response = response.dup
      response.close
      expect(clear_response.status).to eq 200
    end
  end

end