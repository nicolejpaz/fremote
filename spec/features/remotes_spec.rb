require 'spec_helper'

feature 'Create Remote' do
  let!(:user) { FactoryGirl.create :user }
  let!(:fremote) { FactoryGirl.create :fremote }

  before(:each) do
    web_login user
  end

  context 'on host main page' do

    it 'can create remote with valid input' do
      visit root_path
      fill_in 'video_url',   with: "http://www.youtube.com/embed/mZqGqE0D0n4"
      expect{click_button "Create Remote"}.to change{Remote.all.count}.by(1)
      expect(page).to have_content "Congratulations"
    end

    it 'goes to the index page if no url is passed' do
      visit root_path
      fill_in 'video_url',   with: nil
      click_button "Create Remote"
      expect(page).to have_content("URL can't be blank")
    end

    it 'goes to the index page with invalid input' do
      visit root_path
      fill_in 'video_url',   with: "acdefg"
      click_button "Create Remote"
      expect(page).to have_content("Invalid URL")
    end

  end

end
