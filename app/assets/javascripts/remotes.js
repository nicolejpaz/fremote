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
    url: '/remotes/' + Remote.remote_id + "/playlist"
  }).done(function(response){
    console.log(response)
    $.each(response, function(index, item){
      $('#playlist').append('<li class="playlist_item sortable" draggable="true">' + item.title + '</li>')
    })
      $('body .sortable').sortable()
  })

  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + "/ping"
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
      $('#playlist').append('<li class="playlist_item sortable" draggable="true">' + item.title + '</li>')
    })
    $('body .sortable').sortable()

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
        remote_draw(previous_coordinates, coordinate.x_coordinate, coordinate.y_coordinate, coordinate.color)
      }

      previous_coordinates.push(coordinate)
    })
    previous_coordinates = []
  })

  source.addEventListener("clear:" + Remote.remote_id, function(event){
    clear()
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