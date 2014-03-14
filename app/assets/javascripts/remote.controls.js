function updateRemote() {
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/control',
    data: { _method:'PUT', status: Remote.status, start_at: Remote.start_at, sender_id: user },
    dataType: 'JSON'
  })
}

function pingRemote() {
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