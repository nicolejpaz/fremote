require 'spec_helper'

feature 'When a guest visits the landing page' do
  scenario 'they can see the user session links in the navigation' do
    visit root_path

    expect(page).to have_content('Login')
    expect(page).to have_content('Sign up')
  end

  scenario 'they can sign in and out' do
    visit root_path

    click_link 'Sign up'

    fill_in 'user[name]', :with => 'test'
    fill_in 'user[email]', :with => 'test@test.com'
    fill_in 'user[password]', :with => 'pa55word3'
    fill_in 'user[password_confirmation]', :with => 'pa55word3'
    click_button 'Sign up'

    expect(page).to have_content('Welcome, test')

    click_link 'Logout'

    expect(page).to have_content('Login')

    click_link 'Login'

    fill_in 'user[login]', :with => 'test'
    fill_in 'user[password]', :with => 'pa55word3'
    click_button 'Log in'

    expect(page).to have_content('Welcome, test')
  end 

  scenario 'they can create a quick remote' do
    visit root_path

    fill_in 'video_url', :with => 'http://www.youtube.com/watch?v=NX_23r7vYak'
    click_button 'Create Remote'

    click_button 'Send'

    node = page.find('body')

    node.native.inner_html.should include('player')
  end
end

feature 'When a guest creates a remote' do
  before(:each) do
    visit root_path

    fill_in 'video_url', :with => 'http://www.youtube.com/watch?v=NX_23r7vYak'
    click_button 'Create Remote'
  end

  scenario 'they can choose their own guest name for the remote' do
    fill_in 'guest_name', :with => 'test name'
    click_button 'Send'

    page.should have_xpath("//input[contains(@value, 'test')]")
  end

  scenario 'they can modify a remote on the edit page' do
    click_button 'Send'

    click_link 'Edit Remote'

    fill_in 'name', :with => 'New Remote'
    fill_in 'description', :with => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam libero tortor, mattis et nisi vel, adipiscing auctor ipsum. Etiam metus tellus, consequat non urna at, convallis posuere est. Integer eleifend sapien turpis, et pretium neque vulputate sit amet. Aliquam et ligula at odio mollis dapibus pulvinar sed elit. Morbi semper sed diam ac pellentesque. Mauris porttitor ultricies ante, non rhoncus nisi elementum quis. Aliquam aliquet elementum lectus eu tempus. Vestibulum blandit fringilla tempus. Cras congue leo tellus. Curabitur tincidunt metus nulla, vel semper nulla placerat at. Mauris id risus quis nulla dignissim molestie. Curabitur sem metus, vestibulum quis nisi sit amet, scelerisque egestas ligula. Phasellus semper tellus nec eleifend porttitor. Mauris ullamcorper sed sem sed semper. Ut at iaculis nunc, vitae ultrices orci.'
    click_button 'Update Remote'

    click_button 'Send'

    expect(page).to have_content('New Remote')
    expect(page).to have_content('Lorem ipsum')
  end
end