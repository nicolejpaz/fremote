$(document).ready(function() {
  var drawing_canvas = $('canvas')

  draw(drawing_canvas[0])
})

function draw(drawing_canvas, x_coordinate, y_coordinate) {
  var context = drawing_canvas.getContext('2d')
  console.log('in draw')
  draw_on_canvas(drawing_canvas, context, x_coordinate, y_coordinate)
}

function draw_on_canvas(drawing_canvas, context, x_coordinate, y_coordinate) {
  var mousedown = false
  context.strokeStyle = '#0000ff'
  context.lineWidth = 5

  console.log('in drawing on canvas')

  if (x_coordinate) {
    context.beginPath()
    context.moveTo(x_coordinate, y_coordinate)
    context.lineTo(x_coordinate, y_coordinate)
    context.stroke()
  }

  drawing_canvas.onmousedown = function(e) {
    var pos = getMousePos(drawing_canvas, e)

    mousedown = true
    context.beginPath()
    context.moveTo(pos.x, pos.y)

    return false
  }

  drawing_canvas.onmousemove = function(e) {
    e.preventDefault()
    var pos = getMousePos(drawing_canvas, e)

    if (mousedown) {
      context.lineTo(pos.x, pos.y)
      context.stroke()

      $.ajax({
        type: 'POST',
        url: '/remotes/' + Remote.remote_id + '/drawing',
        data: {'x_coordinate': pos.x, 'y_coordinate': pos.y}
      })
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