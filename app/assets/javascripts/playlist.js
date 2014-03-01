$(document).on('ready', function(){
	$('#playlist').on('click', '.playlist-title', function(){
		var self = $(this)
      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id,
        data: { _method:'PUT', status: 0, start_at: Remote.start_at, sender_id: user, selection: $('#playlist li').index(self.parent())},
        dataType: 'JSON'
      })
	})
  $('#playlist_group form').on('ajax:success', function(){
    $('#playlist_url_field').val('')
  })
})

var Playlist = {
  selectedListItem: 0
}

$('#playlist li').on('mousedown', function(){
  Playlist.selectedListItem = $('#playlist li').index(self)
})

