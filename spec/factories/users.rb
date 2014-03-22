FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'test@test.com'
    password 'password'
    password_confirmation 'password'
  end
end