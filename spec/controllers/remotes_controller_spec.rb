require 'spec_helper'

describe RemotesController do
  before(:each) do
    @sample_remote = Remote.make
    @sample_remote.populate('http://www.youtube.com/watch?v=NX_23r7vYak')
    @sample_remote.save
    @sample_coordinates = []
    10.times do |number|
      @sample_coordinates << {x_coordinate: number, y_coordinate: number, color: 'FF0000'}
    end
  end

  describe "GET index" do
    it "assigns @remote to a new remote" do
      get :new
      expect(assigns(:remote).is_a?(Remote)).to eq(true)
    end
  end


  describe "POST create" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
    end

    it "gets the current user if there is one" do
      controller.stub(:current_user){@sample_user}
      post :create, video_url: @sample_video
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "creates a remote with a valid url" do
      count = Remote.all.count
      post :create, video_url: @sample_video
      expect(assigns(:remote).remote_id.length).to eq(10)
      expect(Remote.all.count).to eq(count + 1)
    end

    it "doesn't create a remote with an invalid url" do
      count = Remote.all.count
      post :create, video_url: "junk"
      expect(Remote.all.count).should_not eq(count + 1)
    end
  end


  describe "GET show" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
    end

    it "retrieves @remote from remote_id" do
      get :show, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets the current user if there is one" do
      controller.stub(:current_user){@sample_user}
      get :show, id: @sample_remote.remote_id
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "generates a username for the chat" do
      get :show, id: @sample_remote.remote_id
      expect(assigns(:username).is_a?(String)).to eq(true)
    end

  end

  describe "GET ping" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
    end

    it "retrieves @remote from remote_id" do
      get :ping, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets playlist from remote" do
      get :ping, id: @sample_remote.remote_id
      expect(assigns(:playlist)).to eq(@sample_remote.playlist)
    end

    it "renders json" do
      get :ping, id: @sample_remote.remote_id
      response.body.include?("stream_url").should eq(true)
    end
  end


  describe "PATCH update" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
      @sample_owned_remote = @sample_user.remotes.make
      @sample_owned_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_owned_remote.save
      @another_user = User.create name: "bob", email: "bob@bob.com", password: "password"
    end

    it "retrieves @remote from remote_id" do
      patch :update, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets the current user if there is one" do
      controller.stub(:current_user){@sample_user}
      patch :update, id: @sample_remote.remote_id
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "updates the remote if owner is logged in" do
      controller.stub(:current_user){@sample_user}
      patch :update, remote: { :admin_only => "true" }, id: @sample_owned_remote.remote_id
      expect(assigns(:remote).admin_only).to eq(true)
    end

    xit "doesn't update the remote if owner is not logged in" do
      @sample_owned_remote.admin_only = false
      @sample_owned_remote.save
      sign_out @sample_user
      sign_out
      # sign_in @another_user
      controller.stub(:current_user) { @another_user }
      # controller.stub(:current_user){@another_user}
      patch :update, remote: { :admin_only => "true" }, id: @sample_owned_remote.remote_id
      expect(assigns(:remote).admin_only).to eq(false)
    end

  end


  describe "POST chat" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
    end

    it "retrieves @remote from remote_id" do
      post :chat, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "receives and dispatches a chat message notification" do
      controller.stub(:current_user){@sample_user}
      message = nil
      ActiveSupport::Notifications.subscribe("chat:#{@sample_remote.remote_id}") do |name, start, finish, id, payload|
          message = payload
      end
      post :chat, id: @sample_remote.remote_id, chat_message: "dummy message", name: "dummy"
      until message != nil do
      end
      ActiveSupport::Notifications.unsubscribe("chat:#{@sample_remote.remote_id}")
      expect(JSON.parse(message)["message"]).to eq("dummy message")
    end

  end

  describe "GET time" do
    it "retrieves the time" do
      get :time
      expect(Time.parse(JSON.parse(response.body)["time"]).is_a?(Time)).to eq(true)
    end
  end

  describe "POST drawing" do
    before(:each) do
      @sample_user = User.create name: "john", email: "john@john.com", password: "password"
      @sample_video = "http://www.youtube.com/watch?v=NX_23r7vYak"
      @sample_remote = Remote.make
      @sample_remote.populate("http://www.youtube.com/watch?v=NX_23r7vYak")
      @sample_remote.save
    end

    it "retrieves @remote from remote_id" do
      post :drawing, id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets the current user if there is one" do
      controller.stub(:current_user){@sample_user}
      post :drawing, id: @sample_remote.remote_id
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "receives and dispatches drawing coordinates notification" do
      controller.stub(:current_user){@sample_user}
      coords = nil
      ActiveSupport::Notifications.subscribe("drawing:#{@sample_remote.remote_id}") do |name, start, finish, id, payload|
          coords = payload
      end
      post :drawing, id: @sample_remote.remote_id, coordinates: "dummy coords"
      until coords != nil do
      end
      ActiveSupport::Notifications.unsubscribe("drawing:#{@sample_remote.remote_id}")
      expect(JSON.parse(coords)["coordinates"]).to eq("dummy coords")
    end

    it 'returns an OK response' do
      post :drawing, id: @sample_remote.remote_id, coordinates: @sample_coordinates
      @drawing_response = response.dup
      response.close
      expect(@drawing_response.status).to eq 200
    end

    it 'returns a response that includes the selected color' do
      post :drawing, id: @sample_remote.remote_id, coordinates: @sample_coordinates
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
