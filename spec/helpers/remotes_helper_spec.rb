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
