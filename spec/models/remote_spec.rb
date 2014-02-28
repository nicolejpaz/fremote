require 'spec_helper'

describe Remote do

	before(:each) do
		@attr = {
			url: "http://www.youtube.com/embed/mZqGqE0D0n4",
      name: "Test name",
      description: "Test description"
		}
		 @sample_user = create(:user)
		 @sample_video = "http://www.youtube.com/embed/mZqGqE0D0n4"
	end

	it "should create a new instance given a valid attribute" do
    build(:remote).should be_valid
	end

	it "should be given a status by default" do
		@testvideo = build(:remote)
		@testvideo.status.should eq(-1)
	end

	it "have a remote id attribute" do
		@test_remote = create(:remote)
		@test_remote.populate(@sample_video)
		@test_remote.remote_id.should_not eq(nil)
	end

	it "have a start at attribute that equals zero by default" do
		@testvideo = build(:remote)
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

  it "should have a drawing embedded on initialize" do
    @sample_remote = Remote.new
    @sample_remote.drawing.is_a?(Drawing).should eq true
  end

  it "should have a default name if no name given" do
    @sample_remote = Remote.make
    @sample_remote.populate(@sample_video)
    @sample_remote.save
    @sample_remote.name.should eq "Unnamed video"
  end

  it "should have a default description if no name given" do
    @sample_remote = Remote.make
    @sample_remote.populate(@sample_video)
    @sample_remote.save
    @sample_remote.description.should eq "No description."
  end

  it "should have a custom name if given" do
    @sample_remote = Remote.make
    @sample_remote.populate(@sample_video)
    @sample_remote.name = @attr[:name]
    @sample_remote.save

    @sample_remote.name.should eq "Test name"
  end

  it "should have a custom description if given" do
    @sample_remote = Remote.make
    @sample_remote.populate(@sample_video)
    @sample_remote.description = @attr[:description]
    @sample_remote.save

    @sample_remote.description.should eq "Test description"
  end

end