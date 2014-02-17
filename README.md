Fremote
==============

Fremote is a web app to remote-control YouTube & Vimeo videos.  A user can send a link to a friend(or friends) they are chatting with and they can watch the video/movie at the same time.  Whoever has control of the "remote" can start/pause/fast-forward/rewind the video and it will control the video for every viewer.

## Features

* Server-sent Events via ActionController::Live
* Pub/Sub using ActiveSupport::Notifications
* Video.js API
* Streaming video links provided by Viddl
* MongoDB with Mongoid
* Live chat
* HAML
* User registration with Devise

## Demo

fremote.herokuapp.com

## To Contribute

I'd love for someone to contribute!  Simply fork the repo, make changes, and submit a pull request.

Right now I'm looking for adding more tests, the ability to scrape video information from more providers, playlist capability for remotes, and the ability to draw on top of videos.  Other ideas are also welcome.

## Issues

Needs more tests!

## Team

* Ben Titcomb [@Ravenstine](https://github.com/Ravenstine)
