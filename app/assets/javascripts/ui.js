$(document).on('ready', function(){
  $('#owner_only_tooltip').tooltip()

  var nav = $('#top_nav')

  $(window).scroll(function () {
      if ($(this).scrollTop() > 3) {
          nav.addClass("nav-scrolled")
      } else {
          nav.removeClass("nav-scrolled")
      }
  })
})

$('#owner_controls_form').on('click', function(){
	$('#owner_controls_form').submit()
})

$('body .sortable').sortable().bind('sortupdate', function(e, ui) {
	console.log('sorted')
	console.log(ui)
	console.log(ui.item.index())
	console.log(ui.oldindex)
	$.ajax({
		url: "/remotes/" + Remote.remote_id + "/playlist",
		type: "POST",
		data: {old_position: ui.oldindex, new_position: ui.item.index(), _method: "patch"}
	})
})