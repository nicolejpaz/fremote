require 'spec_helper'

describe Playlist do
  before(:each) do
    @params = attributes_for(:remote)
    @params[:alternate_url] = "https://www.youtube.com/watch?v=R4i8SpNgzA4"

    @sample_user = create(:user)
    @sample_remote = Remote.make(@sample_user)
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    VCR.use_cassette('playlist') do
      @sample_playlist_item = Media.new(@params[:alternate_url])
    end
  end

  it "should add a list item to the playlist" do
    count = @sample_remote.playlist.list.length
    @sample_remote.playlist.add_list_item(@sample_playlist_item)
    expect(@sample_remote.playlist.list.length).to eq (count + 1)
  end

  it "should sort the playlist items given an old position and a new one" do
    @sample_remote.playlist.add_list_item(@sample_playlist_item)
    @sample_remote.playlist.sort_list_item(1, 0)
    expect(@sample_remote.playlist.list[0]).to eq @sample_playlist_item
  end

  it "should delete a list item at a given index" do
    @sample_remote.playlist.add_list_item(@sample_playlist_item)
    count = @sample_remote.playlist.list.length
    @sample_remote.playlist.delete_list_item(1)
    expect(@sample_remote.playlist.list.length).to eq (count - 1)
  end
end
