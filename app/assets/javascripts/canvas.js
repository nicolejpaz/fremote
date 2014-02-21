$(document).ready(function() {
  var drawing_canvas = $('canvas')

  draw(drawing_canvas[0])
})

function draw(drawing_canvas) {
  var context = drawing_canvas.getContext('2d')

  draw_on_canvas(drawing_canvas, context)
}

function draw_on_canvas(drawing_canvas, context) {
  var mousedown = false
  context.strokeStyle = '#0000ff'
  context.lineWidth = 5
  drawing_canvas.onmousedown = function(e) {
    var pos = getMousePos(drawing_canvas, e)

    mousedown = true
    context.beginPath()
    context.moveTo(pos.x, pos.y)
    return false
  }
  drawing_canvas.onmousemove = function(e) {
    var pos = getMousePos(drawing_canvas, e)

    if (mousedown) {
      context.lineTo(pos.x, pos.y)
      context.stroke()
    }
  }
  drawing_canvas.onmouseup = function(e) {
    mousedown = false
  }
}

function getMousePos(drawing_canvas, e) {
  var rect = drawing_canvas.getBoundingClientRect()
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top
  }
}