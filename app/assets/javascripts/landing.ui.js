window.onload = function() {
  changeWindowHeight()
}

window.onresize = function() {
  changeWindowHeight()
}

function changeWindowHeight() {
  var windowHeight = $(window).height()
  $('#on_landing').css('padding-top', windowHeight / 3)
}