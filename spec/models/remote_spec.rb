require 'spec_helper'

describe Remote do

	before(:each) do
		@attr = {
			url: "http://www.youtube.com/embed/mZqGqE0D0n4",
		}
		 @sample_user = User.create name: "john", email: "john@john.com", password: "password"
		 @sample_video = "http://www.youtube.com/embed/mZqGqE0D0n4"
	end

	it "should create a new instance given a valid attribute" do
		Remote.create(@attr)
	end

	it "should be given a status by default" do
		@testvideo = Remote.new(@attr)
		@testvideo.status.should eq(-1)
	end

	it "have a remote id attribute" do
		@test_remote = Remote.create(@attr)
		@test_remote.populate(@sample_video)
		@test_remote.remote_id.should_not eq(nil)
	end

	it "have a start at attribute that equals zero by default" do
		@testvideo = Remote.new(@attr)
		@testvideo.start_at.should equal(0)
	end

	it "should have an owner if created by a user" do
    @sample_remote = Remote.make(@sample_user)
    @sample_remote.populate(@sample_video)
    @sample_remote.save
    @sample_remote.user.should equal(@sample_user)
	end

	it "should not have an owner if not created by a user" do
    @sample_remote = Remote.make(nil)
    @sample_remote.populate(@sample_video)
    @sample_remote.save
    @sample_remote.user.should equal(nil)
	end

	it "should have a playlist embedded on initialize" do
		@sample_remote = Remote.new
		@sample_remote.playlist.is_a?(Playlist).should equal(true)
	end

end