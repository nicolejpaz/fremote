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

  $('#clear_playlist').on('click', function() {
    $.ajax({
      type: 'POST',
      url: '/remotes/' + Remote.remote_id + '/playlist',
      data: { _method: 'DELETE', clear: $('#playlist li').length },
      dataType: 'JSON'
    })
  })

  $('#playlist_group form').on('ajax:success', function(){
    $('#playlist_url_field').val('')
  })

  $('ol.sortable').sortable()

  $('ol.sortable').sortable().bind('sortupdate', function(e, ui) {
    $('#playlist_group').block()
    $.ajax({
      url: "/remotes/" + Remote.remote_id + "/playlist",
      type: "POST",
      data: {old_position: ui.oldindex, new_position: ui.item.index(), _method: "patch"}
    }).done(function(){
      $('#playlist_group').unblock()
    })
  })

  $('#playlist').on('click', ".playlist-delete", function(e){
    e.preventDefault()
    var index = $(this).parent().index()
    $.ajax({
      url: "/remotes/" + Remote.remote_id + "/playlist",
      type: "POST",
      data: {index: index, _method: "delete"}
    })
  })
})

var Playlist = {
  selectedListItem: 0
}

$('#playlist li').on('mousedown', function(){
  Playlist.selectedListItem = $('#playlist li').index(self)
})
