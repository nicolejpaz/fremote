require 'faker'

FactoryGirl.define do
  factory :remote do |f|
    f.url         "https://www.youtube.com/watch?v=NX_23r7vYak"
    f.name        Faker::Lorem.sentence.slice(1..60)
    f.description Faker::Lorem.paragraph.slice(1..5000)
  end
end