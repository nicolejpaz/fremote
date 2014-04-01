require 'spec_helper'
require 'faker'

describe Remote do

	before(:each) do
		@params = attributes_for(:remote)
    @params[:alternate_name] = Faker::Lorem.sentence.slice(1...60)
    @params[:alternate_description] = Faker::Lorem.paragraph.slice(1...5000)
    @sample_user = create(:user)
	  @another_user = create(:user, name: Faker::Internet.user_name.slice(1...16), email: Faker::Internet.email)
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

    VCR.use_cassette('remote') do
  		@test_remote.populate(@params[:url])
		end
    @test_remote.remote_id.should_not eq(nil)
	end

	it "have a start at attribute that equals zero by default" do
		@testvideo = build(:remote)
		@testvideo.start_at.should equal(0)
	end

	it "should have an owner if created by a user" do
    @sample_remote = Remote.make(@sample_user)

    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @sample_remote.user.should equal(@sample_user)
	end

	it "should not have an owner if not created by a user" do
    @sample_remote = Remote.make(nil)
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
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
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @sample_remote.name.should eq "Unnamed Remote"
  end

  it "should have a default description if no name given" do
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @sample_remote.description.should eq "No description."
  end

  it "should have a custom name if given" do
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.name = @params[:name]
    @sample_remote.save

    @sample_remote.name.should eq @params[:name]
  end

  it "should have a custom description if given" do
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.description = @params[:description]
    @sample_remote.save

    @sample_remote.description.should eq @params[:description]
  end

  it "should rename a remote if the parameters include a :name key" do
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @params[:name] = @params[:alternate_name]
    @sample_remote.update(@params)

    expect(@sample_remote.name).to eq @params[:alternate_name]
  end

  it "should change a remote description if the parameters include a :description key" do
    @sample_remote = Remote.make
    VCR.use_cassette('remote') do
      @sample_remote.populate(@params[:url])
    end
    @sample_remote.save

    @params[:description] = @params[:alternate_description]
    @sample_remote.update(@params)

    expect(@sample_remote.description).to eq @params[:alternate_description]
  end

  context "when checking the user type" do
    it "should return 'guest' if a guest created the remote" do
      @sample_remote = Remote.make
      VCR.use_cassette('remote') do
        @sample_remote.populate(@params[:url])
      end
      @sample_remote.save 

      guest = @sample_remote.kind_of_user
      expect(guest).to eq "guest"
    end

    it "should return 'owner' if the remote's owner is also logged in" do
      @sample_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_remote.populate(@params[:url])
      end
      @sample_remote.save 

      owner = @sample_remote.kind_of_user(@sample_user)

      expect(owner).to eq "owner"
    end

    it "should return 'user' if there is a user but they are not the remote's owner" do
      @sample_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_remote.populate(@params[:url])
      end
      @sample_remote.save 

      user = @sample_remote.kind_of_user(@another_user)

      expect(user).to eq "user"
    end
  end
end