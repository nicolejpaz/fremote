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
