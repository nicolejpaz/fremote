$(document).on('ready', function(){
	$('#playlist_table').on('click', '.playlist_item', function(){
		var self = $(this)
      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id,
        data: { _method:'PUT', status: 0, start_at: Remote.start_at, sender_id: user, selection: self.closest('td').parent()[0].sectionRowIndex},
        dataType: 'JSON'
      })
      console.log('playlist_item_clicked')
	})
})