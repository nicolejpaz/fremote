Remote.update = function(){
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id,
    data: { _method:'PUT', status: Remote.status, start_at: Remote.start_at, sender_id: user },
    dataType: 'JSON'
  })
}

Remote.ping = function(){
  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + "/ping"
  })
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

var send = true

var player = videojs('player')

player.ready(function(){

  var source = new EventSource(Remote.remote_id + '/stream')

  source.addEventListener("control:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
    console.log(user)
    console.log(data.sender_id == user)
    if (data.status == -1 || data.status == 2){
      player.currentTime(data.start_at)
      player.play() // to bypass the big button mode
      player.pause()
    } else if (data.status == 1){
      var offset = Math.max(0, (Remote.date - Date.parse(data.updated_at)) / 1000 )
      player.currentTime(Math.floor(data.start_at + offset))
      player.play()     
    }
  })

  source.addEventListener("chat:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
    $('#chat_message').val('')
    $('#chat_table_body').prepend('<tr>' + '<td>' + data.message + '</td>' + '<td class="grey-text">' + data.name + '</td>' + '</tr>')
  })

  source.addEventListener("drawing:" + Remote.remote_id, function(event){
    var data = JSON.parse(event.data)
    console.log(data)
    // console.log(source)

    var drawing_canvas = $('canvas')[0]
    console.log('drawing on the other end')
    // draw(drawing_canvas, data.x_coordinate, data.y_coordinate)
  })

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

  player.on('timeupdate', function(){
    player.loadingSpinner.hide()
  })
})

player.on('loadedmetadata', function(){
  Remote.ping()    
})