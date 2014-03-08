window.onload = function() {
  changeWindowHeight()
}

window.onresize = function() {
  changeWindowHeight()
}

function changeWindowHeight() {
  var windowHeight = $(window).height()
  $('#center_column').css('padding-top', windowHeight / 3)
}