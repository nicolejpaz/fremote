$(document).ready(function() {
  var localCanvas = $('canvas')

  var canvas = new Canvas(localCanvas)

  $.ajax({
    type: 'GET',
    url: '/remotes/' + Remote.remote_id + '/read'
  }).done(function(data){
    var previous_coordinates = []

    $.each(data, function(index, coordinate) {
      if (previous_coordinates.length >= 1) {
        canvas.remoteDraw(previous_coordinates, coordinate.x_coordinate, coordinate.y_coordinate, coordinate.color, coordinate.line)
      }

      previous_coordinates.push(coordinate)
    })
  })

  canvas.draw()

  $('button#clear').on('click', function(e) {
    $.ajax({
      type: 'POST',
      url: '/remotes/' + Remote.remote_id + '/clear'
    })
  })
})

var Canvas = function(canvas) {
  this.canvas = canvas[0]
  this.context = this.canvas.getContext('2d')
}

Canvas.prototype.color = function() {
  var color = $('input#color').val()

  return color
}

Canvas.prototype.line = function() {
  var line = $('input#line').val()
  return line
}

var mousedown = false
var currentCoordinates = []
var saveCoordinates = []

function onMouseDown(targetCanvas) {
  targetCanvas.onmousedown = function(e) {
    var pos = getMousePos(targetCanvas, e)
    mousedown = true
    return false
  }
}

function onMouseMove(targetCanvas, color, line) {
  targetCanvas.onmousemove = function(e) {
    e.preventDefault()
    var pos = getMousePos(targetCanvas, e)

    $('input#color').on('change', function(e) {
      color = $('input#color').val()
    })
    $('input#line').on('change', function(e) {
      line = $('input#line').val()
    })
    if (mousedown) {
      currentCoordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': color, 'line': line})
      saveCoordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': color, 'line': line})

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

function saveCoordinatesIfCorrectLength() {
  if (saveCoordinates.length >= 100) {
    sendToSaveCoordinates(saveCoordinates)

    var newCurrent = [saveCoordinates[saveCoordinates.length-1]]
    saveCoordinates = newCurrent
  }
}

function onMouseUp(targetCanvas) {
  targetCanvas.onmouseup = function(e) {
    mousedown = false
    
    sendCoordinates(currentCoordinates)
    sendToSaveCoordinates(saveCoordinates)
    
    currentCoordinates = []
  }
}

Canvas.prototype.draw = function() {
  var color = this.color()
  var line = this.line()
  var targetCanvas = this.canvas

  onMouseDown(targetCanvas)
  onMouseMove(targetCanvas, color, line)
  onMouseUp(targetCanvas)
}

Canvas.prototype.clear = function() {
  var canvas = this.canvas
  canvas.width = canvas.width
}

Canvas.prototype.remoteDraw = function(previous_coordinates, x_coordinate, y_coordinate, color, line) {
  var remote_canvas = this.canvas
  var context = remote_canvas.getContext('2d')

  context.strokeStyle = color
  context.lineWidth = line

  if (x_coordinate != null) {
    drawOnRemoteCanvas(previous_coordinates, x_coordinate, y_coordinate, context, color, line)
  }
}

function drawOnRemoteCanvas(previous_coordinates, x_coordinate, y_coordinate, context, color, line) {
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
    url: '/remotes/' + Remote.remote_id + '/drawings',
    data: {_method: 'PUT', 'coordinates': currentCoordinates}
  })
}

function sendToSaveCoordinates(saveCoordinates) {
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/write',
    data: {'coordinates': saveCoordinates}
  })
}

function getMousePos(drawing_canvas, e) {
  var rect = drawing_canvas.getBoundingClientRect()
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top
  }
}