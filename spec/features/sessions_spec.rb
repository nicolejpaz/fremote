require 'spec_helper'

feature 'When a user creates an account and logs in' do
  before(:all) do
    @params = { user_name:     Faker::Internet.user_name,
                email:         Faker::Internet.email,
                password:      Faker::Internet.password
              }
  end
  
  before(:each) do
    visit root_path
  end

  scenario 'they can see the user session links in the navigation' do
    expect(page).to have_content('Login')
    expect(page).to have_content('Sign up')
  end

  scenario 'they can sign in and out' do
    click_link 'Sign up'

    fill_in 'user[name]', :with => @params[:user_name]
    fill_in 'user[email]', :with => @params[:email]
    fill_in 'user[password]', :with => @params[:password]
    fill_in 'user[password_confirmation]', :with => @params[:password]
    click_button 'Sign up'

    expect(page).to have_content('Welcome, ' + @params[:user_name])

    click_link 'Logout'

    expect(page).to have_content('Login')

    click_link 'Login'

    fill_in 'user[login]', :with => @params[:user_name]
    fill_in 'user[password]', :with => @params[:password]
    click_button 'Log in'

    expect(page).to have_content('Welcome, ' + @params[:user_name])
  end 
end
