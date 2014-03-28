require 'faker'

pass = Faker::Internet.password

FactoryGirl.define do
  factory :user do
    name                  Faker::Internet.user_name.slice(1..15)
    email                 Faker::Internet.email
    password              pass
    password_confirmation pass
  end
end