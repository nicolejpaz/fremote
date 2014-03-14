Remote.update = function(){
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/control',
    data: { _method:'PUT', status: Remote.status, start_at: Remote.start_at, sender_id: user },
    dataType: 'JSON'
  })
}

Remote.ping = function(){
  createPlaylist()

  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + "/ping"
  }).done(function(data){
    if (data.stream_url != undefined){
      player.src(data.stream_url)
      player.one('loadedmetadata', function(){
        Remote.toggle(data)
      })
    } else {
      Remote.toggle(data)
    }
  })
}

Remote.pause = function(start_at){
  player.currentTime(start_at)
  player.play() // to bypass the big button mode
  player.pause()
}

Remote.play = function(start_at, updated_at){
  var offset = Math.max(0, (this.date - Date.parse(updated_at)) / 1000 )
  player.currentTime(Math.floor(start_at + offset))
  player.play()
}

Remote.toggle = function(data){
  if (data.status == -1 || data.status == 2){
    this.pause(data.start_at)
  } else if (data.status == 1){
    this.play(data.start_at, data.updated_at)
  }
}

synchronizeTime()

var player = videojs('player')

player.ready(function(){

  var source = new EventSource(Remote.remote_id + '/stream')
  var RemoteCanvas = $('canvas')
  var canvas = new Canvas(RemoteCanvas)
  var alertClosed = $('div.alert-danger')

  if (source.readyState === 0) {
    // Connecting
    alertClosed.hide()
  }

  source.onopen = function() {
    // Connected
    alertClosed.hide()
  }

  source.onerror = function() {
    // Disconnected
    alertClosed.show()
  }

  source.addEventListener("watch:" + Remote.remote_id, function(event){
    getWatchers(event)
  })

  source.addEventListener("unwatch:" + Remote.remote_id, function(event){
    resetWatchers(event)
  })

  source.addEventListener("control:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    if (data.stream_url != undefined){
      player.src(data.stream_url)
      player.one('loadedmetadata', function(){
        Remote.toggle(data)
      })
    } else {
      Remote.toggle(data)
    }
  })

  source.addEventListener("playlist_sort:" + Remote.remote_id, function(event){
    sortPlaylist(event)
  })

  source.addEventListener("playlist_block:" + Remote.remote_id, function(event){
    blockPlaylist(event)
  })

  source.addEventListener("playlist_add:" + Remote.remote_id, function(event){
    addToPlaylist(event)
  })

  source.addEventListener("playlist_delete:" + Remote.remote_id, function(event){
    deleteFromPlaylist(event)
  })

  source.addEventListener("playlist_clear:" + Remote.remote_id, function(event) {
    clearPlaylist(event)   
  })

  source.addEventListener("chat:" + Remote.remote_id, function(event){
    sendChatMessage(event)
  })

  source.addEventListener("drawing:" + Remote.remote_id, function(event){
    initiateDrawingOnEventListener(event, canvas)
  })

  source.addEventListener("clear:" + Remote.remote_id, function(event){
    clearCanvas(canvas)
  })

  window.onunload = function() {
    source.close()
  }

  $(document).on('userplay', function(){
    Remote.status = 1
    Remote.start_at = player.currentTime()
    Remote.update()
  })

  $(document).on('userpause', function(){
    Remote.status = 2
    Remote.start_at = player.currentTime()
    Remote.update()
  })


  player.on('ended', function(){
    Remote.status = 0
    Remote.update()
  })

  player.on('timeupdate', function(){
    player.loadingSpinner.hide()
  })

})

player.ready(function(){
  Remote.ping()
})
