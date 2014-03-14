var playlistItemHead = '<li class="playlist_item sortable" draggable="true"><a class="playlist-title">'
var playlistItemFoot = '</a><button style="float: right;" class="btn btn-xfs btn-danger playlist-delete">X</button></li>'

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

  var Playlist = {
    selectedListItem: 0
  }

  $('#playlist li').on('mousedown', function(){
    Playlist.selectedListItem = $('#playlist li').index(self)
  })
})

function sortPlaylist(event) {
  var data = JSON.parse(event.data)

  $('#playlist').html('')

  $.each(data.playlist, function(index, item){
    $('#playlist').append(playlistItemHead + item.title + playlistItemFoot)
  })

  $('#playlist').sortable()
}

function blockPlaylist(event) {
  var data = JSON.parse(event.data)
  data = JSON.parse(data)

  if(data.block == true){
    $('#playlist_group').block({ css: { backgroundColor: '#006c51', color: '#fff', border: 'none' }, message: '<h3>modifying playlist</h3>' })
  } else {
    $('#playlist_group').unblock()
  }
}

function addToPlaylist(event) {
  var data = JSON.parse(event.data)

  $('#playlist').append(playlistItemHead + JSON.parse(data).title + playlistItemFoot)
  $('#playlist').sortable()
}

function deleteFromPlaylist(event) {
  var data = JSON.parse(event.data)
  var index = parseInt(JSON.parse(data).index)

  var list_item = $('#playlist .playlist_item')[index]
  $(list_item).remove()
}

function clearPlaylist(event) {
  $('#playlist li').remove() 
}

function createPlaylist() {
  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + "/playlist"
  }).done(function(response){
    $.each(response, function(index, item){
      $('#playlist').append(playlistItemHead + item.title + playlistItemFoot)
    })
    $('#playlist').sortable()
  })
}