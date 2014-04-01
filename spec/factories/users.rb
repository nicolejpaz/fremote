require 'faker'

pass = Faker::Internet.password(9)

FactoryGirl.define do
  factory :user do
    name                  Faker::Internet.user_name.tr('^a-zA-Z0-9\-\_\s', '').slice(1..15)
    email                 Faker::Internet.email
    password              pass
    password_confirmation pass
  end
end