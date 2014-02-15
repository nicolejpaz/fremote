
    Remote.update = function(){
      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id,
        data: { _method:'PUT', status: Remote.status, start_at: Remote.start_at, sender: user },
        dataType: 'JSON'
      })
    }

    var source = new EventSource(Remote.remote_id + '/stream')

    var user = Math.floor((Math.random()*10000)+1)

    var send = true

    var player = videojs('player')

    player.ready(function(){

      player.on('play', function(){
        Remote.status = 1
        Remote.start_at = player.currentTime()
        Remote.update()
      })

      player.on('pause', function(){
        Remote.status = 2
        Remote.start_at = player.currentTime()
        Remote.update()
      })

      player.on('timeupdate', function(){
        player.loadingSpinner.hide()
      })

    })

    source.addEventListener(Remote.remote_id, function(event){
      var data = JSON.parse(event.data)
      console.log(data)
      console.log(data.sender == user)
      if (data.sender != user){
        player.currentTime(data.start_at)
        if (data.status == -1){
          player.pause()
        } else if (data.status == 1){
          player.play()
        } else if (data.status == 2){
          player.pause()
        }
      }

    })

    // source.addEventListener("chat:" + Remote.remote_id, function(event){
    //   var data = JSON.parse(event.data)
    //   console.log(data)
    // })