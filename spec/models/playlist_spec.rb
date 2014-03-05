require 'spec_helper'

describe Playlist do
  before(:each) do
    @sample_user = create(:user)
    @sample_remote = Remote.make(@sample_user)
    @sample_remote.populate('http://www.youtube.com/watch?v=NX_23r7vYak')
    @sample_remote.save
    @sample_playlist_item = Media.new('https://www.youtube.com/watch?v=zoO0s1ukcqQ')
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
