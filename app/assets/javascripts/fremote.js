$(document).on('ready', function(){
  if (typeof remote_id !== 'undefined') {
    var stream = new Stream()
    var remote = new Remote()
    var player = new Player(stream.source, remote)
    var chat = new Chat(stream.source, remote)
    var canvas = new Canvas(stream.source, remote)
    var playlist = new Playlist(stream.source, remote)
    var watcher_list = new WatcherList(stream.source, remote)
  }
})
