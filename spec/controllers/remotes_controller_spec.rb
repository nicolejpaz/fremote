require 'spec_helper'
require 'faker'

describe RemotesController do
  before(:each) do
    @sample_user = create(:user)
    @another_user = create(:user, name: Faker::Internet.user_name.tr('^a-zA-Z0-9\-\_\s', '').slice(1..15), email: Faker::Internet.email)

    @params = attributes_for(:remote)
    @params[:alternate_name] = Faker::Lorem.sentence.slice(1...60)

    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.name = @params[:name]
    @sample_remote.description = @params[:description]
    @sample_remote.save
  end

  describe "GET index" do
    it "assigns @remote to a new remote" do
      get :index
      expect(assigns(:remote).is_a?(Remote)).to eq(true)
    end
  end

  describe "GET new" do
    context "when there is a current user" do
      before(:each) do
        controller.stub(:current_user){@sample_user}
        get :new
      end
      
      it "assigns the current user to @user" do
        expect(assigns(:user)).to eq @sample_user
      end

      it "assigns @remote to a new remote" do
        expect(assigns(:remote).is_a?(Remote)).to eq true
      end
    end

    context "when there is no current user" do
      before(:each) do
        get :new
      end

      it "does not assign any user to @user" do
        expect(assigns(:user)).to be_nil
      end

      it "does not assign @remote to a new remote" do
        expect(assigns(:remote)).to be_nil
      end
    end
  end

  describe "POST create" do
    it "creates a remote with a valid url" do
      count = Remote.all.count
      VCR.use_cassette('remote') do
        post :create, video_url: @params[:url], name: @params[:name], description: @params[:description]
      end
      expect(assigns(:remote).remote_id.length).to eq(10)
      expect(Remote.all.count).to eq(count + 1)
    end

    context "when a user is logged in" do
      before(:each) do
        controller.stub(:current_user){@sample_user}
        VCR.use_cassette('remote') do
          post :create, video_url: @params[:url], name: @params[:name], description: @params[:description]
        end
      end

      it "assigns the current user to @user" do
        expect(assigns(:user)).to eq @sample_user
      end

      it "should contain a remote with the current user as the remote owner" do
        expect(Remote.last.user).to eq @sample_user
      end
    end

    context "when a user is not logged in" do
      before(:each) do
        VCR.use_cassette('remote') do
          post :create, video_url: @params[:url], name: @params[:name], description: @params[:description]
        end
      end

      it "does not assign @user" do
        expect(assigns(:user)).to be_nil
      end
    end
  end

  describe "GET show" do
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
      VCR.use_cassette('remote') do
        get :ping, id: @sample_remote.remote_id
      end
    end
    
    it "retrieves @remote from remote_id" do
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "gets playlist from remote" do
      expect(assigns(:playlist)).to eq(@sample_remote.playlist)
    end

    it "renders json" do
      response.body.include?("stream_url").should eq(true)
    end
  end

  describe "PUT control" do
    before(:each) do
      @sample_owned_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_owned_remote.populate(@params[:url])
      end
      @sample_owned_remote.admin_only = true
      @sample_owned_remote.save
    end

    context "when the current user is the remote owner" do
      before(:each) do
        controller.stub(:current_user){@sample_user}
        put :control, remote: { :admin_only => "false" }, id: @sample_owned_remote.remote_id
      end

      it "retrieves @remote from remote_id" do
        expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
      end

      it "gets the current user if there is one" do
        expect(assigns(:user)).to eq @sample_user
      end

      it "updates the remote" do
        expect(assigns(:remote).admin_only).to eq(false)
      end
    end

    context "when the current user is not the remote owner" do
      before(:each) do
        controller.stub(:current_user){@another_user}
        put :control, remote: { :admin_only => "false" }, id: @sample_owned_remote.remote_id
      end

      it "gets the current user if there is one" do
        expect(assigns(:user)).to eq @another_user
      end

      it "retrieves @remote from remote_id" do
        expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
      end 

      it "does not update the remote" do
        expect(assigns(:remote).admin_only).to eq true
      end
    end

    context "when the current user is a guest" do
      before(:each) do
        put :control, remote: { :admin_only => "false" }, id: @sample_owned_remote.remote_id
      end

      it "does not assign @user" do
        expect(assigns(:user)).to be_nil
      end

      it "retrieves @remote from remote_id" do
        expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
      end 

      it "does not update the remote" do
        expect(assigns(:remote).admin_only).to eq true
      end
    end
  end

  describe "GET time" do
    it "retrieves the time" do
      get :time
      expect(Time.parse(JSON.parse(response.body)["time"]).is_a?(Time)).to eq(true)
    end
  end

  describe "PATCH update" do
    before(:each) do
      @sample_owned_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_owned_remote.populate(@params[:url])
      end
      @sample_owned_remote.name = @params[:name]
      @sample_owned_remote.description = @params[:description]
      @sample_owned_remote.save  
    end

    context "when the current user is the remote owner" do
      before(:each) do
        controller.stub(:current_user){@sample_user}
        patch :update, id: @sample_owned_remote.remote_id, name: @params[:alternate_name]
      end

      it "gets the current user if there is one" do
        expect(assigns(:user)).to eq @sample_user 
      end

      it "retrieves @remote from remote_id" do
        expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
      end

      it "updates the remote based off of the given parameters" do
        expect(Remote.last.name).to eq @params[:alternate_name]
      end
    end

    context "when the current user is not the remote owner" do
      before(:each) do
        controller.stub(:current_user){@another_user}
      end

      context "and the remote is not admin_only" do
        before(:each) do
          patch :update, id: @sample_owned_remote.remote_id, name: @params[:alternate_name]
        end
        
        it "assigns the current user to @user" do
          expect(assigns(:user)).to eq @another_user
        end

        it "retrieves @remote from remote_id" do
          expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
        end

        it "updates the remote's attributes" do
          expect(Remote.last.name).to eq @params[:alternate_name]
        end
      end

      context "and the only the remote owner is allowed to modify the remote" do
        before(:each) do
          @sample_owned_remote.authorization.update_permissions({"_user" => {}, "_member" => {}, "_guest" => {}})
          @sample_owned_remote.save  

          patch :update, id: @sample_owned_remote.remote_id, name: @params[:alternate_name]
        end

        it "assigns the current user to @user" do
          expect(assigns(:user)).to eq @another_user
        end

        it "retrieves @remote from remote_id" do
          expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
        end

        it "does not update the remote's attributes" do
          expect(Remote.last.name).to_not eq @params[:alternate_name]
        end       
      end
    end

    context "when the current user is a guest" do
      context "and the remote is not admin_only" do
        before(:each) do
          patch :update, id: @sample_owned_remote.remote_id, name: @params[:alternate_name]
        end

        it "does not assign @user" do
          expect(assigns(:user)).to be_nil
        end

        it "retrieves @remote from remote_id" do
          expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
        end

        it "updates the remote's attributes" do
          expect(Remote.last.name).to eq @params[:alternate_name]
        end
      end

      context "and the remote is admin_only" do
        before(:each) do
          @sample_owned_remote.authorization.update_permissions({"_user" => {}, "_member" => {}, "_guest" => {}})
          @sample_owned_remote.save
          
          patch :update, id: @sample_owned_remote.remote_id, name: @params[:alternate_name]
        end

        it "does not assign @user" do
          expect(assigns(:user)).to be_nil
        end

        it "retrieves @remote from remote_id" do
          expect(assigns(:remote).remote_id).to eq @sample_owned_remote.remote_id
        end

        it "does not update the remote's attributes" do
          expect(Remote.last.name).to_not eq @params[:alternate_name]
        end
      end
    end
  end

  describe 'GET edit' do
    before(:each) do
      @sample_owned_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_owned_remote.populate(@params[:url])
      end
      @sample_owned_remote.save
    end

    it 'assigns the current remote to @remote' do
      get :edit, id: @sample_owned_remote.remote_id
      expect(assigns(:remote)).to eq @sample_owned_remote
    end

    context 'when the current user is logged in' do
      context 'and the current user is also the remote owner' do
        before(:each) do
          controller.stub(:current_user){@sample_user}
          get :edit, id: @sample_owned_remote.remote_id
        end

        it 'assigns the current user to @user' do
          expect(assigns(:user)).to eq @sample_user
        end

        it 'assigns the current user to @remote_owner' do
          expect(assigns(:remote_owner)).to eq @sample_user
        end
      end

      context 'and the current user is not the remote owner' do
        before(:each) do
          @password = Faker::Internet.password(8)
          @another_user = create(:user, name: Faker::Internet.user_name.tr('^a-zA-Z0-9\-\_\s', '').slice(1..15), email: Faker::Internet.email, password: @password, password_confirmation: @password)
          controller.stub(:current_user){@another_user}
          get :edit, id: @sample_owned_remote.remote_id
        end

        it 'assigns the current user to @user' do
          expect(assigns(:user)).to eq @another_user
        end

        it 'does not assign the current user to @remote_owner' do
          expect(assigns(:remote_owner)).to eq nil
        end
      end
    end

    context 'when the current user is a guest' do
      before(:each) do
        get :edit, id: @sample_owned_remote.remote_id
      end

      it 'does not assign @user' do
        expect(assigns(:user)).to eq nil
      end
    end
  end

  context 'POST change' do
    before(:each) do
      VCR.use_cassette('playlist') do
        @added_item = Media.new("https://www.youtube.com/watch?v=R4i8SpNgzA4")
      end

      @sample_remote.playlist.add_list_item(@added_item)
    end
    
    it 'adds to the remote\'s votes' do
      VCR.use_cassette('playlist') do
        post :change, id: @sample_remote.remote_id
      end

      expect(@sample_remote.playlist.votes).to eq 0
    end 
  end
end
