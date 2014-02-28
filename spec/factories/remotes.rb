# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :remote do |f|
    f.url "http://www.youtube.com/embed/mZqGqE0D0n4"
    f.name "Test Name"
    f.description "Test description"
  end
end