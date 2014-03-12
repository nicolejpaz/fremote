var playlistItemHead = '<li class="playlist_item sortable" draggable="true"><a class="playlist-title">'
var playlistItemFoot = '</a><button style="float: right;" class="btn btn-xfs btn-danger playlist-delete">X</button></li>'


Remote.update = function(){
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/control',
    data: { _method:'PUT', status: Remote.status, start_at: Remote.start_at, sender_id: user },
    dataType: 'JSON'
  })
}

Remote.ping = function(){
  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + "/playlist"
  }).done(function(response){
    console.log(response)
    $.each(response, function(index, item){
      $('#playlist').append(playlistItemHead + item.title + playlistItemFoot)
    })
      $('#playlist').sortable()
  })

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


// Synchronize time with server.  Use this instead of Date.now().
$.ajax({
  type: 'GET',
  url: '/time',
  async: false,
  dataType: 'JSON'
}).done(function(response){
  Remote.date = Date.parse(response.time)
  setInterval(function(){Remote.date = Remote.date + 1000},1000);
})

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
    var data = JSON.parse(event.data)
    console.log(data)
    $('#watchers').html('')
    $.each(data.watchers, function(index, watcher){
      displayWatcher(watcher)
    })
    $('#playlist').sortable()
  })

  source.addEventListener("unwatch:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    $('#watchers').html('')
    $.each(data.watchers, function(index, watcher){
      displayWatcher(watcher)
    })
    $('#playlist').sortable()
  })

  source.addEventListener("control:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
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
    var data = JSON.parse(event.data)
    console.log(data)

    $('#playlist').html('')

    $.each(data.playlist, function(index, item){
      $('#playlist').append(playlistItemHead + item.title + playlistItemFoot)
    })
    $('#playlist').sortable()

  })

  source.addEventListener("playlist_block:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    data = JSON.parse(data)
    if(data.block == true){
      $('#playlist_group').block({ css: { backgroundColor: '#006c51', color: '#fff', border: 'none' }, message: '<h3>modifying playlist</h3>' })
    } else {
      $('#playlist_group').unblock()
    }
  })

  source.addEventListener("playlist_add:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)

    $('#playlist').append(playlistItemHead + JSON.parse(data).title + playlistItemFoot)
    $('#playlist').sortable()
  })

  source.addEventListener("playlist_delete:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
    var index = parseInt(JSON.parse(data).index)

    var list_item = $('#playlist .playlist_item')[index]
    $(list_item).remove()
  })

  source.addEventListener("playlist_clear:" + Remote.remote_id, function(event) {
    $('#playlist li').remove()    
  })

  source.addEventListener("chat:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
    $('#chat_message').val('')
    $('#chat_table_body').prepend('<tr>' + '<td>' + data.message + '</td>' + '<td class="grey-text">' + data.name + '</td>' + '</tr>')
  })

  source.addEventListener("drawing:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    var previous_coordinates = []

    $.each(data['coordinates'], function(index, coordinate) {
      if (previous_coordinates.length >= 1) {
        canvas.remoteDraw(previous_coordinates, coordinate.x_coordinate, coordinate.y_coordinate, coordinate.color, coordinate.line)
      }

      previous_coordinates.push(coordinate)
    })
    previous_coordinates = []
  })

  source.addEventListener("clear:" + Remote.remote_id, function(event){
    canvas.clear()
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

function displayWatcher(watcher) {
  if (watcher.user_kind === 'owner') {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-star owner"></span></li>')
  } else if (watcher.user_kind === 'member') {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '<span class="glyphicon glyphicon-user member"></span></li>')
  } else {
    $('#watchers').append('<li id="' + watcher.username.toLowerCase() + '" class="' + watcher.user_kind + '">' + watcher.username + '</li>')
  }
}