require 'spec_helper'

feature "Create Remote" do
  context "on landing page" do
    context "can create remote with valid input" do
      it "can create remote with Youtube link using ViddlRb" do
        visit "root_path"
        fill_in video_url,   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
        expect{click_button "Create Remote"}.to change{Remote.all.count}.by(1)
        expect(page).to have_content "Congratulations"
      end

      it "can create a remote from a direct link with a valid extension" do
        visit root_path
        fill_in video_url, with: "https://ia700302.us.archive.org/29/items/CC_1916_12_04_TheRink/CC_1916_12_04_TheRink_512kb.mp4"
        expect{click_button "Create Remote"}.to change{Remote.all.count}.by(1)
        expect(page).to have_content "Congratulations"
      end
    end

    it "goes to the index page if no url is passed" do
      visit root_path
      fill_in "video_url",   with: nil
      click_button "Create Remote"
      expect(page).to have_content("URL can't be blank")
    end

    it "goes to the index page with invalid input" do
      visit root_path
      fill_in "video_url",   with: "acdefg"
      click_button "Create Remote"
      expect(page).to have_content("Invalid URL")
    end
  end
end

feature "View Remote" do
  context "on show page" do
    it "can show a video player" do
      visit root_path
      fill_in "video_url",   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
      expect{click_button "Create Remote"}.to change{Remote.all.count}.by(1)
      click_button "Send"
      node = page.find("body")
      node.native.inner_html.should include("video")
    end

    context "when a guest creates a remote" do
      it "allows the guest to create a temporary chat name" do
        visit root_path
        fill_in "video_url",   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
        click_button "Create Remote"
        fill_in "guest_name", with: "test name"
        click_button "Send"
        node = page.find('body')
        node.native.inner_html.should include("test")
      end

      it "allows the guest to have an auto-generated chat name if they do not fill out the guest chat name form" do
        visit root_path
        fill_in "video_url",   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
        click_button "Create Remote"
        click_button "Send"
        node = page.find("body")
        node.native.inner_html.should include("anon")
      end
    end

    it "can display new chat messages" do
      visit root_path
      fill_in "video_url",   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
      click_button "Create Remote"
      click_button "Send"
      node = page.find("body")
      node.native.inner_html.should include('id="chat"')
      fill_in "chat_message", with: "hello world"
      click_button "Send"
      node.native.inner_html.should include("hello world")
    end
  end
end


feature "Remote Owner Controls" do
  context "on show page and new page" do
    it "can display control to restrict remote control" do
      sample_user = User.create name: "john", email: "john@john.com", password: "password"
      visit user_session_path
      fill_in "user_login",   with: "john@john.com"
      fill_in "user_password", with: "password"
      click_button "Log in"
      node = page.find("body")
      node.native.inner_html.should include("Owner-only")
      fill_in "video_url",   with: "http://www.youtube.com/watch?v=zoO0s1ukcqQ"
      expect{click_button "Create Remote"}.to change{Remote.all.count}.by(1)
      node = page.find("body")
      node.native.inner_html.should include("Owner-only")
    end
  end
end
