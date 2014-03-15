$(document).on('ready', function(){
  var stream = new Stream()
  var playlist = new Playlist(stream.source)
  var remote = new Remote(stream.source, playlist)
  var player = new Player(stream.source, remote)
})