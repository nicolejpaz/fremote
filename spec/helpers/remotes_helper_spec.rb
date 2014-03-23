require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the RemotesHelper. For example:
#
# describe RemotesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
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
      @another_user = create(:user, name: 'Another user', email: 'testasdgh@test.com')
      @sample_remote = Remote.make(@sample_user)
      VCR.use_cassette('create_owned_remote') do
        @sample_remote.populate('https://www.youtube.com/watch?v=NX_23r7vYak')
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
      @one_word_user_name = create(:user, name: 'One')
      @two_word_user_name = create(:user, name: 'One Two', email: 'testtwo@test.com')
      @three_word_user_name = create(:user, name: 'One Two Three', email: 'testthree@test.com')
    end

    it "returns the user's name if their name is one word" do
      expect(sanitized_name(@one_word_user_name)).to eq 'One'
    end

    it "returns the user's sanitzed name if their name is two words" do
      expect(sanitized_name(@two_word_user_name)).to eq 'One_Two'
    end

    it "returns the user's sanitized name if their name is three words" do
      expect(sanitized_name(@three_word_user_name)).to eq 'One_Two_Three'
    end
  end
end
