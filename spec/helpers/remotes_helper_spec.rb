require 'spec_helper'
require 'faker'

describe RemotesHelper do
  context "to_boolean" do
    it "should convert true string to true boolean" do
      to_boolean("true").should equal(true)
    end

    it "should convert false string to false boolean" do
      to_boolean("false").should equal(false)
    end

    it "should convert zero string to false boolean" do
      to_boolean("0").should equal(false)
    end

    it "should convert zero integer to false boolean" do
      to_boolean(0).should equal(false)
    end

    it "should convert one string to true boolean" do
      to_boolean("1").should equal(true)
    end

    it "should convert one integer to true boolean" do
      to_boolean(1).should equal(true)
    end
  end

  context "is_authorized?" do
    before(:each) do
      @sample_user = create(:user)
      @another_user = create(:user, name: Faker::Internet.user_name, email: Faker::Internet.email)

      @sample_remote = Remote.make(@sample_user)
      VCR.use_cassette('remote') do
        @sample_remote.populate("https://www.youtube.com/watch?v=NX_23r7vYak")
      end
      @sample_remote.save
    end

    it "should return true if a user is authorized to use a remote" do
      @sample_remote.admin_only = false
      @sample_remote.save 

      expect(is_authorized?(@sample_remote, @another_user))
    end

    it "should return false if a user is not authorized to use a remote" do
      @sample_remote.admin_only = true
      @sample_remote.save

      expect(is_authorized?(@sample_remote, @another_user))
    end

    it "should return true if a guest is authorized to use a remote" do
      @sample_remote.admin_only = false
      @sample_remote.save 

      expect(is_authorized?(@sample_remote))
    end

    it "should return false if a guest is not authorized to use a remote" do
      @sample_remote.admin_only = true
      @sample_remote.save

      expect(is_authorized?(@sample_remote))
    end
  end

  context "sanitized_name" do
    before(:all) do
      @params = {
                  one:   create_user_name(1),
                  two:   create_user_name(2),
                  three: create_user_name(3)
                }

      @one_word_user_name   = create(:user, name: @params[:one])
      @two_word_user_name   = create(:user, name: @params[:two], email: Faker::Internet.email)
      @three_word_user_name = create(:user, name: @params[:three], email: Faker::Internet.email)
    end

    it "returns the user's name if their name is one word" do
      expect(sanitized_name(@one_word_user_name)).to eq @params[:one]
    end

    it "returns the user's sanitzed name if their name is two words" do
      expect(sanitized_name(@two_word_user_name)).to eq @params[:two].gsub(' ', '_')
    end

    it "returns the user's sanitized name if their name is three words" do
      expect(sanitized_name(@three_word_user_name)).to eq @params[:three].gsub(' ', '_')
    end
  end
end

private

def create_user_name(num)
  slice_needed = 16 / num
  user_name = ''

  num.times do
    user_name += Faker::Internet.user_name.gsub('_', '').slice(1...slice_needed) + ' '
  end
  
  user_name.gsub(/\s$/, '')
end
