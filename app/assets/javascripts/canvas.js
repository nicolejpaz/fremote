$(document).ready(function() {
  var localCanvas = $('canvas')

  var canvas = new Canvas(localCanvas)

  canvas.draw()

  // $('button#clear').on('click', function(e) {
  //   clear()
  //   $.ajax({
  //     type: 'POST',
  //     url: '/remotes/' + Remote.remote_id + '/clear'
  //   })
  // })
})

var Canvas = function(canvas) {
  this.canvas = canvas
  this.context = canvas[0].getContext('2d')
}

Canvas.prototype.color = function() {
  var color = $('input#color').val()

  $('input#color').on('change', function(e) {
    color = $('input#color').val()
  })
  return color
}

var mousedown = false

function onMouseDown(targetCanvas) {
  targetCanvas.onmousedown = function(e) {
    var pos = getMousePos(targetCanvas, e)
    mousedown = true
    return false
  }
}

Canvas.prototype.draw = function() {
  var color = this.color()

  var targetCanvas = this.canvas[0]

  onMouseDown(targetCanvas)

  var currentCoordinates = []

  targetCanvas.onmousemove = function(e) {
    e.preventDefault()
    var pos = getMousePos(targetCanvas, e)

    if (mousedown) {
      currentCoordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': color})

      if (currentCoordinates.length >= 10) {
        sendCoordinates(currentCoordinates)

        var new_current = [currentCoordinates[currentCoordinates.length-1]]
        currentCoordinates = new_current
      }
    }
  }

  targetCanvas.onmouseup = function(e) {
    mousedown = false
    
    sendCoordinates(currentCoordinates)
    currentCoordinates = []
  }
}

// function clear() {
//   var drawing_canvas = $('canvas')[0]
//   drawing_canvas.width = drawing_canvas.width
// }

function remote_draw(previous_coordinates, x_coordinate, y_coordinate, color) {
  var remote_canvas = $('canvas')[0]
  var context = remote_canvas.getContext('2d')

  context.strokeStyle = color
  context.lineWidth = 5

  if (x_coordinate != null) {

    var length = previous_coordinates.length - 1
    var prev_x = parseInt(previous_coordinates[length]['x_coordinate'])
    var prev_y = parseInt(previous_coordinates[length]['y_coordinate'])

    var x = parseInt(x_coordinate)
    var y = parseInt(y_coordinate)

    context.beginPath()
    context.moveTo(prev_x, prev_y)
    context.lineTo(x, y)
    context.stroke()
  }
}

function sendCoordinates(currentCoordinates) {
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/drawing',
    data: {'coordinates': currentCoordinates}
  })
}

function getMousePos(drawing_canvas, e) {
  var rect = drawing_canvas.getBoundingClientRect()
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top
  }
}