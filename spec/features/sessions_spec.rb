require 'spec_helper'

feature 'When a user creates an account and logs in' do
  before(:each) do
    visit root_path
  end

  scenario 'they can see the user session links in the navigation' do
    expect(page).to have_content('Login')
    expect(page).to have_content('Sign up')
  end

  scenario 'they can sign in and out' do
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
end