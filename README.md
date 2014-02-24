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

[fremote.herokuapp.com](http://fremote.herokuapp.com/)

## To Contribute

We'd love for someone to contribute!  Simply fork the repo, make changes, and submit a pull request.

Right now I'm looking to add the following:

* "Currently Viewing" list of users who are watching a video.
* Playlist capability for remotes.  This may put into question how remotes are created, however. [in progress]
* ~~"Fremote Lite", which would have the feature of embedding any video and relying on a timer and user intervention to sync up videos.~~
* Scrape video information from more providers. [in progress]

Other ideas are also welcome.

## Issues

* Latency-correction needs to be improved for playback.

## Team

* Ben Titcomb [@Ravenstine](https://github.com/Ravenstine)
* Nicole Paz [@nicolejpaz](https://github.com/nicolejpaz)
