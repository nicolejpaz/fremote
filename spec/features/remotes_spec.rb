require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

describe 'When a guest visits the landing page' do
  it 'they can create a quick remote' do
    visit root_path

    fill_in 'video_url', :with => 'https://www.youtube.com/watch?v=NX_23r7vYak'
    VCR.use_cassette('remote') do
      click_button 'Create Remote'
    end

    click_button 'Use Remote'

    node = page.find('body')

    node.native.inner_html.should include('player')
  end

  it 'they cannot create a new remote if the url field is blank' do
    visit root_path

    click_button 'Create Remote'

    expect(page).to have_content('URL can\'t be blank')
  end

  it 'they cannot create a new remote if the url is invalid' do
    visit root_path

    fill_in :video_url, with: 'invalid_url'
    click_button 'Create Remote'

    expect(page).to have_content('The video URL you provided is invalid.')
  end
end

describe 'When a guest creates a remote' do
  before(:each) do
    visit root_path

    fill_in 'video_url', :with => 'https://www.youtube.com/watch?v=NX_23r7vYak'
    VCR.use_cassette('remote') do
      click_button 'Create Remote'
    end
  end

  it 'they can choose their own guest name for the remote' do
    fill_in 'guest_name', :with => 'test name'
    click_button 'Use Remote'

    page.should have_xpath("//input[contains(@value, 'test')]")
  end

  it 'they can modify a remote on the edit page' do
    click_button 'Use Remote'

    click_link 'Edit Remote'

    fill_in 'name', :with => 'New Remote'
    fill_in 'description', :with => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam libero tortor, mattis et nisi vel, adipiscing auctor ipsum. Etiam metus tellus, consequat non urna at, convallis posuere est. Integer eleifend sapien turpis, et pretium neque vulputate sit amet. Aliquam et ligula at odio mollis dapibus pulvinar sed elit. Morbi semper sed diam ac pellentesque. Mauris porttitor ultricies ante, non rhoncus nisi elementum quis. Aliquam aliquet elementum lectus eu tempus. Vestibulum blandit fringilla tempus. Cras congue leo tellus. Curabitur tincidunt metus nulla, vel semper nulla placerat at. Mauris id risus quis nulla dignissim molestie. Curabitur sem metus, vestibulum quis nisi sit amet, scelerisque egestas ligula. Phasellus semper tellus nec eleifend porttitor. Mauris ullamcorper sed sem sed semper. Ut at iaculis nunc, vitae ultrices orci.'
    click_button 'Update Remote'

    click_button 'Use Remote'

    expect(page).to have_content('New Remote')
    expect(page).to have_content('Lorem ipsum')
  end
end

describe 'When a user is logged in' do
  before(:each) do
    user = create(:user)
    login_as(user, :scope => :user)

    visit root_path
  end
  
  it 'they can create a remote on remotes#new' do
    expect(page).to have_content('New remote')

    click_link 'New remote'

    fill_in 'name', :with => 'New Name'
    fill_in 'description', :with => 'A description.'
    click_button 'Create Remote'

    expect(page).to have_content('New Name')
    expect(page).to have_content('A description.')
  end

  it 'they can edit the remote' do
    expect(page).to have_content('New remote')

    click_link 'New remote'

    fill_in 'name', :with => 'New Name'
    fill_in 'description', :with => 'A description.'
    click_button 'Create Remote'

    expect(page).to have_content('Edit Remote')

    click_link 'Edit Remote'

    fill_in 'name', :with => 'Another Name'
    click_button 'Update Remote'

    expect(page).to have_content('Another Name')
  end

  it 'they can create a remote with no name or description and it assigns it a default name' do
    expect(page).to have_content('New remote')

    click_link'New remote'

    click_button 'Create Remote'

    expect(page).to have_content('Unnamed Remote')
    expect(page).to have_content('No description.')
  end

  it 'they can create a remote that does not allow a guest to update the remote' do
    expect(page).to have_content('New remote')

    click_link 'New remote'
    click_button 'Create Remote'

    click_link 'Logout'
    click_button 'Use Remote'
    
    expect(page).to_not have_content('Edit Remote')  
    expect(page).to have_content('You are a guest of this remote')
  end
end

describe 'When a user creates a new remote, the default permissions are in place' do
  context 'a guest' do
      before(:each) do
      user = create(:user)
      login_as(user, :scope => :user)

      visit root_path

      expect(page).to have_content('New remote')

      click_link 'New remote'
      click_button 'Create Remote'

      click_link 'Logout'
      click_button 'Use Remote'
    end

    it 'can chat' do
      expect(page).to have_content('Welcome to Fremote chat.  If you would like a dedicated username for the chat, sign up for an account!')
    end

    it 'cannot modify the playlist' do
      expect(page).to have_content('You are a guest of this remote, so you do not have permission to add to this playlist.')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end

    it 'cannot draw on the screen' do
      expect(page).to_not have_content('Clear Screen')
    end
  end

  context 'a user that is not a member or the remote owner' do
    before(:each) do
      user = create(:user)
      login_as(user, :scope => :user)

      visit root_path

      expect(page).to have_content('New remote')

      click_link 'New remote'
      click_button 'Create Remote'

      click_link 'Logout'
      click_link 'Sign up'

      fill_in 'user[name]', :with => 'another test'
      fill_in 'user[email]', :with => 'test2@test.com'
      fill_in 'user[password]', :with => 'pa55word3'
      fill_in 'user[password_confirmation]', :with => 'pa55word3'
      click_button 'Sign up'

      expect(page).to have_content('Welcome, another test')
    end

    it 'can chat' do
      expect(page).to have_content('Welcome to Fremote chat.')
      expect(page).to_not have_content('If you would like a dedicated username for the chat, sign up for an account!')
    end

    it 'cannot modify the playlist' do
      expect(page).to have_content('You are a user of this remote, so you do not have permission to add to this playlist.')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end

    it 'cannot draw on the screen' do
      expect(page).to_not have_content('Clear Screen')
    end
  end

  context 'a member' do
    before(:each) do
      visit root_path

      click_link 'Sign up'

      fill_in 'user[name]', :with => 'tester'
      fill_in 'user[email]', :with => 'test@test.com'
      fill_in 'user[password]', :with => 'pa55word3'
      fill_in 'user[password_confirmation]', :with => 'pa55word3'
      click_button 'Sign up'

      expect(page).to have_content('Welcome, tester')

      click_link 'Logout'

      click_link 'Sign up'

      fill_in 'user[name]', :with => 'another tester'
      fill_in 'user[email]', :with => 'test2@test.com'
      fill_in 'user[password]', :with => 'pa55word3'
      fill_in 'user[password_confirmation]', :with => 'pa55word3'
      click_button 'Sign up'    

      expect(page).to have_content('Welcome, another tester')

      click_link 'New remote'

      fill_in 'member[]', :with => 'tester'
      click_button 'Create Remote'

      click_link 'Logout'

      click_link 'Login'

      fill_in 'user[login]', :with => 'tester'
      fill_in 'user[password]', :with => 'pa55word3'
      click_button 'Log in'

      expect(page).to have_content('Welcome, tester')
    end

    it 'can chat' do
      expect(page).to have_content('Welcome to Fremote chat.')
      expect(page).to_not have_content('If you would like a dedicated username for the chat, sign up for an account!')
    end

    it 'can modify the playlist' do
      expect(page).to have_content('Clear Playlist')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end

    it 'can draw on the screen' do
      expect(page).to have_content('Clear Screen')
    end
  end
end

describe 'When a user creates a new remote, they can set the permissions of the remote individually' do
  before(:each) do
    visit root_path

    click_link 'Sign up'

    fill_in 'user[name]', :with => 'tester'
    fill_in 'user[email]', :with => 'test@test.com'
    fill_in 'user[password]', :with => 'pa55word3'
    fill_in 'user[password_confirmation]', :with => 'pa55word3'
    click_button 'Sign up'

    expect(page).to have_content('Welcome, tester')

    click_link 'Logout'

    click_link 'Sign up'

    fill_in 'user[name]', :with => 'another tester'
    fill_in 'user[email]', :with => 'test2@test.com'
    fill_in 'user[password]', :with => 'pa55word3'
    fill_in 'user[password_confirmation]', :with => 'pa55word3'
    click_button 'Sign up'    

    expect(page).to have_content('Welcome, another tester')

    click_link 'New remote'

    fill_in 'member[]', :with => 'tester'
    uncheck '_guest[chat]'
    uncheck '_guest[control]'
    uncheck '_guest[playlist]'
    uncheck '_guest[draw]'
    uncheck '_guest[settings]'

    uncheck '_user[chat]'
    uncheck '_user[control]'
    uncheck '_user[playlist]'
    uncheck '_user[draw]'
    uncheck '_user[settings]'

    uncheck '_member[chat]'
    uncheck '_member[control]'
    uncheck '_member[playlist]'
    uncheck '_member[draw]'
    uncheck '_member[settings]'
    click_button 'Create Remote'

    click_link 'Logout'
  end

  context 'a guest' do
    before(:each) do
      click_button 'Use Remote'
    end
    
    it 'cannot use the chat' do
      expect(page).to have_content('You are a guest of this remote, so you do not have permission to chat.')
    end

    it 'cannot draw' do
      expect(page).to_not have_content('Clear Screen')
    end

    it 'cannot add to the playlist' do
      expect(page).to have_content('You are a guest of this remote, so you do not have permission to add to this playlist.')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end
  end

  context 'a user who is not a member or remote owner' do
    before(:each) do
      click_link 'Sign up'

      fill_in 'user[name]', :with => 'this tester'
      fill_in 'user[email]', :with => 'test3@test.com'
      fill_in 'user[password]', :with => 'pa55word3'
      fill_in 'user[password_confirmation]', :with => 'pa55word3'
      click_button 'Sign up'

      expect(page).to have_content('Welcome, this tester')
    end
    
    it 'cannot use the chat' do
      expect(page).to have_content('You are a user of this remote, so you do not have permission to chat.')
    end

    it 'cannot draw' do
      expect(page).to_not have_content('Clear Screen')
    end

    it 'cannot add to the playlist' do
      expect(page).to have_content('You are a user of this remote, so you do not have permission to add to this playlist.')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end
  end

  context 'a member' do
    before(:each) do
      click_link 'Login'

      fill_in 'user[login]', :with => 'tester'
      fill_in 'user[password]', :with => 'pa55word3'
      click_button 'Log in'

      expect(page).to have_content('Welcome, tester')      
    end

    it 'cannot use the chat' do
      expect(page).to have_content('You are a member of this remote, so you do not have permission to chat.')
    end

    it 'cannot draw' do
      expect(page).to_not have_content('Clear Screen')
    end

    it 'cannot add to the playlist' do
      expect(page).to have_content('You are a member of this remote, so you do not have permission to add to this playlist.')
    end

    it 'cannot modify the remote settings' do
      expect(page).to_not have_content('Edit Remote')
    end    
  end
end
