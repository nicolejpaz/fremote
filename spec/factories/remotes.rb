require 'faker'

FactoryGirl.define do
  factory :remote do |f|
    f.url         "http://www.youtube.com/embed/mZqGqE0D0n4"
    f.name        Faker::Lorem.sentence.slice(1..60)
    f.description Faker::Lorem.paragraph.slice(1..5000)
  end
end