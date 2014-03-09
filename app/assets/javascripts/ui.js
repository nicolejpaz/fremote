$(document).on('ready', function(){
  $('#owner_only_tooltip').tooltip()

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

$('#owner_controls_form').on('click', function(){
	$('#owner_controls_form').submit()
})

