require 'spec_helper'

describe PlaylistsController do
  before(:each) do
    @sample_remote = create(:remote)
    @sample_remote = Remote.make
    @sample_remote.populate('http://www.youtube.com/watch?v=NX_23r7vYak')
    @sample_remote.save

    @sample_user = User.create name: "john", email: "john@john.com", password: "password"
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
      expect(response.body).to include "http://www.youtube.com/watch?v=NX_23r7vYak"
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

    it "should assign the remote's playlist to @playlist" do
      delete :destroy, remote_id: @sample_remote.remote_id
      expect(assigns(:playlist)).to eq @sample_remote.playlist
    end
  end
end