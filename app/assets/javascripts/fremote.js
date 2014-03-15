$(document).on('ready', function(){
  var stream = new Stream()
  var remote = new Remote(stream.source)
  var player = new Player(stream.source, remote)
  var chat = new Chat(stream.source, remote)
  var playlist = new Playlist(stream.source, remote)
})