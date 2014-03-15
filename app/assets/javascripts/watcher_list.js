function WatcherList(source, remote){

  var watchersElement = $('#watchers')
  source.addEventListener("watch:" + remote.remoteId, function(event){
    self.getWatchers(event)
  })

  source.addEventListener("unwatch:" + remote.remoteId, function(event){
    self.resetWatchers(event)
  })

  self.displayWatcher = function(watcher) {
    if (watcher.user_kind === 'owner') {
      watchersElement.append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-star owner"></span></li>')
    } else if (watcher.user_kind === 'member') {
      watchersElement.append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-user member"></span></li>')
    } else {
      watchersElement.append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '</li>')
    }
  }

  self.getWatchers = function(event) {
    var data = JSON.parse(event.data)

    watchersElement.html('')

    $.each(data.watchers, function(index, watcher){
      self.displayWatcher(watcher)
    })
  }

  self.resetWatchers = function(event) {
    var data = JSON.parse(event.data)

    watchersElement.html('')
    
    $.each(data.watchers, function(index, watcher){
      self.displayWatcher(watcher)
    })
    
  }

}