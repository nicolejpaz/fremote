require 'spec_helper'

describe Remote do

	before(:each) do
		@attr = {
			video_id: "mZqGqE0D0n4", 
			provider: "YouTube", 
			title: "Cherry Bloom - King Of The Knife",
			description: "The first video from the upcoming album Secret Sounds, to download in-stores April 14. Checkout http://www.cherrybloom.net",
			duration: 175,
			date: "Sat Apr 12 22:25:35 UTC 2008",
			thumbnail_small: "http://i.ytimg.com/vi/mZqGqE0D0n4/default.jpg",
			thumbnail_medium: "http://i.ytimg.com/vi/mZqGqE0D0n4/mqdefault.jpg",
			thumbnail_large: "http://i.ytimg.com/vi/mZqGqE0D0n4/hqdefault.jpg",
			embed_url: "http://www.youtube.com/embed/mZqGqE0D0n4",
			embed_code: '<iframe src="http://www.youtube.com/embed/mZqGqE0D0n4" frameborder="0" allowfullscreen="allowfullscreen"></iframe>'
		}
	end

	it "should create a new instance given a valid attribute" do
		Remote.create(@attr)
	end

	it "should be given a status by default" do
		@testvideo = Remote.new(@attr)
		@testvideo.status.should eq(-1)
	end

	it "have a video id attribute" do
		Remote.new(@attr.merge(:video_id => ""))
		should_not be_valid
	end

	it "have a start at attribute that equals zero by default" do
		@testvideo = Remote.new(@attr)
		@testvideo.start_at.should equal(0)
	end

end