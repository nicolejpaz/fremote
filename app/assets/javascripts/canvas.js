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
var currentCoordinates = []

function onMouseDown(targetCanvas) {
  targetCanvas.onmousedown = function(e) {
    var pos = getMousePos(targetCanvas, e)
    mousedown = true
    return false
  }
}

function onMouseMove(targetCanvas, color) {
  targetCanvas.onmousemove = function(e) {
    e.preventDefault()
    var pos = getMousePos(targetCanvas, e)

    if (mousedown) {
      currentCoordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': color})

      sendCoordinatesIfCorrectLength()
    }
  }
}

function sendCoordinatesIfCorrectLength() {
  if (currentCoordinates.length >= 10) {
    sendCoordinates(currentCoordinates)

    var newCurrent = [currentCoordinates[currentCoordinates.length-1]]
    currentCoordinates = newCurrent
  }
}

function onMouseUp(targetCanvas) {
  targetCanvas.onmouseup = function(e) {
    mousedown = false
    
    sendCoordinates(currentCoordinates)
    currentCoordinates = []
  }
}

Canvas.prototype.draw = function() {
  var color = this.color()

  var targetCanvas = this.canvas[0]

  onMouseDown(targetCanvas)
  onMouseMove(targetCanvas, color)
  onMouseUp(targetCanvas)
}

// function clear() {
//   var drawing_canvas = $('canvas')[0]
//   drawing_canvas.width = drawing_canvas.width
// }

function remoteDraw(previous_coordinates, x_coordinate, y_coordinate, color) {
  var remote_canvas = $('canvas')[0]
  var context = remote_canvas.getContext('2d')

  context.strokeStyle = color
  context.lineWidth = 5

  if (x_coordinate != null) {
    drawOnRemoteCanvas(previous_coordinates, x_coordinate, y_coordinate, context, color)
  }
}

function drawOnRemoteCanvas(previous_coordinates, x_coordinate, y_coordinate, context, color) {
  var length = previous_coordinates.length - 1,
      prev_x = parseInt(previous_coordinates[length]['x_coordinate']),
      prev_y = parseInt(previous_coordinates[length]['y_coordinate']),
      x = parseInt(x_coordinate),
      y = parseInt(y_coordinate)

  context.beginPath()
  context.moveTo(prev_x, prev_y)
  context.lineTo(x, y)
  context.stroke()
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