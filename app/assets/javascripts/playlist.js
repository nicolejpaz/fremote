$(document).on('ready', function(){
	$('#playlist').on('click', '.playlist_item', function(){
		var self = $(this)
      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id,
        data: { _method:'PUT', status: 0, start_at: Remote.start_at, sender_id: user, selection: $('#playlist li').index(self)},
        dataType: 'JSON'
      })
      console.log(self.closest('li').parent()[0].sectionRowIndex)
      console.log('playlist_item_clicked')
	})
})