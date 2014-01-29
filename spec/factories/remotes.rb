# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :remote do
    video_id "mZqGqE0D0n4"
    provider "YouTube"
    title "Cherry Bloom - King Of The Knife"
    description "The first video from the upcoming album Secret Sounds, to download in-stores April 14. Checkout http://www.cherrybloom.net"
    duration 175
    thumbnail_small "http://i.ytimg.com/vi/mZqGqE0D0n4/default.jpg"
    thumbnail_medium "http://i.ytimg.com/vi/mZqGqE0D0n4/mqdefault.jpg"
    thumbnail_large "http://i.ytimg.com/vi/mZqGqE0D0n4/hqdefault.jpg"
    embed_url "http://www.youtube.com/embed/mZqGqE0D0n4"
    embed_code '<iframe src="http://www.youtube.com/embed/mZqGqE0D0n4" frameborder="0" allowfullscreen="allowfullscreen"></iframe>'
    date "Sat Apr 12 22:25:35 UTC 2008"
  end
end