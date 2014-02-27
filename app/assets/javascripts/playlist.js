$(document).on('ready', function(){
	$('#playlist').on('click', '.playlist_item', function(){
		var self = $(this)
      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id,
        data: { _method:'PUT', status: 0, start_at: Remote.start_at, sender_id: user, selection: $('#playlist li').index(self)},
        dataType: 'JSON'
      })
      // console.log(self.closest('li').parent()[0].sectionRowIndex)
	})
})

var Playlist = {
  selectedListItem: 0
}

$('#playlist li').on('mousedown', function(){
  Playlist.selectedListItem = $('#playlist li').index(self)
})