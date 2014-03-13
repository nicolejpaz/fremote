function displayWatcher(watcher) {
  if (watcher.user_kind === 'owner') {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-star owner"></span></li>')
  } else if (watcher.user_kind === 'member') {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-user member"></span></li>')
  } else {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '</li>')
  }
}