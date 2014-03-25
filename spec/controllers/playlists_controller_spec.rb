require 'spec_helper'

describe PlaylistsController do
  before(:each) do
    @params = {
      name: "Test name",
      alternate_name: "Alternate name",
      description: "Test description",
      video_url: "https://www.youtube.com/watch?v=NX_23r7vYak"
    }

    @sample_remote = create(:remote)
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:video_url])
    end
    @sample_remote.save

    @sample_user = create(:user, name: "john", email: "john@john.com")
  end

  context "GET show" do
    it "should assign the correct remote to @remote" do
      get :show, remote_id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq @sample_remote
    end

    it "assigns the remote's playlist to @playlist" do
      get :show, remote_id: @sample_remote.remote_id
      expect(assigns(:playlist)).to eq @sample_remote.playlist
    end

    it "should include the remote's link in the response's body" do
      get :show, remote_id: @sample_remote.remote_id
      expect(response.body).to include @params[:video_url]
    end
  end

  context "POST create" do
    before(:each) do
      controller.stub(:current_user){@sample_user}
      @playlist_count = @sample_remote.playlist.list.count

      VCR.use_cassette("create_playlist_item") do
        post :create, remote_id: @sample_remote.remote_id, url: "https://www.youtube.com/watch?v=R4i8SpNgzA4"
      end
    end

    it "assigns @user when there is a user" do
      expect(assigns(:user)).to eq(@sample_user)
    end

    it "assigns @remote to the correct remote" do
      expect(assigns(:remote)).to eq(@sample_remote)
    end

    it "assigns @playlist to the remote's playlist" do
      expect(assigns(:playlist)).to eq(@sample_remote.playlist)
    end

    it "adds a playlist item to the playlist" do
      expect(Remote.last.playlist.list.count).to eq(@playlist_count + 1)
    end
  end

  context "PUT update" do
    it "should not assign the current user to @user if there is none" do
      put :update, remote_id: @sample_remote.remote_id
      expect(assigns(:user)).to be_nil
    end

    it "should assign the current user to @user if there is one" do
      controller.stub(:current_user){@sample_user}
      put :update, remote_id: @sample_remote.remote_id
      expect(assigns(:user)).to eq @sample_user
    end

    it "should assign the correct remote to @remote" do
      get :show, remote_id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq @sample_remote
    end

    it "should assign the remote's playlist to @playlist" do
      put :update, remote_id: @sample_remote.remote_id
      expect(assigns(:playlist)).to eq @sample_remote.playlist
    end
  end

  context "DELETE destroy" do
    it "should not assign the current user to @user if there is none" do
      delete :destroy, remote_id: @sample_remote.remote_id
      expect(assigns(:user)).to be_nil
    end

    it "should assign the current user to @user if there is one" do
      controller.stub(:current_user){@sample_user}
      delete :destroy, remote_id: @sample_remote.remote_id
      expect(assigns(:user)).to eq @sample_user
    end

    it "should assign the remote's playlist to @playlist" do
      delete :destroy, remote_id: @sample_remote.remote_id
      expect(assigns(:playlist)).to eq @sample_remote.playlist
    end

    it "should assign the correct remote to @remote" do
      delete :destroy, remote_id: @sample_remote.remote_id
      expect(assigns(:remote)).to eq @sample_remote
    end

    it "should delete all playlist items if params[:clear]" do
      delete :destroy, remote_id: @sample_remote.remote_id, clear: true
      expect(Remote.last.playlist.list).to eq []
    end

    it "should delete the specified list item if params[:index]" do
      delete :destroy, remote_id: @sample_remote.remote_id, index: 0
      expect(Remote.last.playlist.list.first).to_not eq @sample_remote.playlist.list.first
    end
  end
end