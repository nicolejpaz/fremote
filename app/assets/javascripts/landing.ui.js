window.onload = function() {
  var windowHeight = $(window).height()
  $('#center_column').css('padding-top', windowHeight / 3)
}

window.onresize = function() {
  var windowHeight = $(window).height()
  $('#center_column').css('padding-top', windowHeight / 3)
}