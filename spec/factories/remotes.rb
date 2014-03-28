require 'faker'

FactoryGirl.define do
  factory :remote do |f|
    f.url         "http://www.youtube.com/embed/mZqGqE0D0n4"
    f.name        Faker::Lorem.sentence
    f.description Faker::Lorem.paragraph
  end
end