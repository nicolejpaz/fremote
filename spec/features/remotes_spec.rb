require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'When a guest visits the landing page' do
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

feature 'When a user is logged in' do
  before(:each) do
    user = create(:user)
    login_as(user, :scope => :user)

    visit root_path
  end
  
  scenario 'they can create a remote on remotes#new' do
    expect(page).to have_content('New Remote')

    click_link('New Remote')

    fill_in 'name', :with => 'New Name'
    fill_in 'description', :with => 'A description.'
    click_button('Create Remote')

    expect(page).to have_content('New Name')
    expect(page).to have_content('A description.')
  end

  scenario 'they can edit the remote' do
    expect(page).to have_content('New Remote')

    click_link('New Remote')

    fill_in 'name', :with => 'New Name'
    fill_in 'description', :with => 'A description.'
    click_button('Create Remote')

    expect(page).to have_content('Edit Remote')

    click_link('Edit Remote')

    fill_in 'name', :with => 'Another Name'
    click_button 'Update Remote'

    expect(page).to have_content('Another Name')
  end

  scenario 'they can create a remote with no name or description and it assigns it a default name' do
    expect(page).to have_content('New Remote')

    click_link('New Remote')

    click_button('Create Remote')

    expect(page).to have_content('Unnamed Remote')
    expect(page).to have_content('No description.')
  end

  scenario 'they can create a remote that does not allow a guest to update the remote' do
    expect(page).to have_content('New Remote')

    click_link('New Remote')
    click_button('Create Remote')

    click_link('Logout')
    click_button('Send')
    
    expect(page).to_not have_content('Edit Remote')  
    expect(page).to have_content('You are a guest of this remote')
  end
end