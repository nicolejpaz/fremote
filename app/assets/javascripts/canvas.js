function Canvas(source, remote){
  var canvas = $('canvas')
  var video = $('#player')[0]
  var self = this
  var mousedown = false
  var currentCoordinates = []
  var saveCoordinates = []
  self.canvas = canvas[0]
  self.context = self.canvas.getContext('2d')

  $('button#clear').on('click', function(e) {
    $.ajax({
      type: 'POST',
      url: '/remotes/' + remote.remoteId + '/clear'
    })
  })

  self.drawOnRemoteCanvas = function(previousCoordinates, x_coordinate, y_coordinate) {
    var length = previousCoordinates.length - 1,
        prevX = parseInt(previousCoordinates[length]['x_coordinate']),
        prevY = parseInt(previousCoordinates[length]['y_coordinate']),
        x = parseInt(x_coordinate),
        y = parseInt(y_coordinate)

    self.context.beginPath()
    self.context.moveTo(prevX, prevY)
    self.context.lineTo(x, y)
    self.context.stroke()
  }

  self.remoteDraw = function(previousCoordinates, x_coordinate, y_coordinate, color, line) {
    self.context.strokeStyle = color
    self.context.lineWidth = line

    if (x_coordinate != null) {
      self.drawOnRemoteCanvas(previousCoordinates, x_coordinate, y_coordinate, color, line)
    }
  }

  self.initiateDrawingOnEventListener = function(e) {
    var data = JSON.parse(e.data)
    var previousCoordinates = []

    $.each(data['coordinates'], function(index, coordinate) {
      if (previousCoordinates.length >= 1) {
        self.remoteDraw(previousCoordinates, coordinate.x_coordinate, coordinate.y_coordinate, coordinate.color, coordinate.line)
      }

      previousCoordinates.push(coordinate)
    })
    previousCoordinates = []
  }

  source.addEventListener("drawing:" + remote.remoteId, function(e){
    self.initiateDrawingOnEventListener(e)
  })

  self.clear = function() {
    self.canvas.width = self.canvas.width
  }

  source.addEventListener("clear:" + remote.remoteId, function(event){
    self.clear()
  })

  self.color = function(){
    var color = $('input#color').val()
    return color
  }

  self.line = function() {
    var line = $('input#line').val()
    return line
  }

  self.getMousePos = function(e) {
    var rect = self.canvas.getBoundingClientRect()
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    }
  }

  self.onMouseDown = function() {
    self.canvas.onmousedown = function(e) {
      var pos = self.getMousePos(e)
      mousedown = true
      return false
    }
  }

  self.sendCoordinates = function(currentCoordinates) {
    saveCoordinates.push(currentCoordinates)
    $.ajax({
      type: 'POST',
      url: '/remotes/' + remote.remoteId + '/drawings',
      data: {_method: 'PUT', 'coordinates': currentCoordinates}
    })
  }

  self.sendCoordinatesIfCorrectLength = function() {
    if (currentCoordinates.length >= 10) {
      self.sendCoordinates(currentCoordinates)

      var newCurrent = [currentCoordinates[currentCoordinates.length-1]]
      currentCoordinates = newCurrent
    }
  }

  self.onMouseMove = function() {
    self.canvas.onmousemove = function(e) {
      e.preventDefault()
      var pos = self.getMousePos(e)

      if (mousedown) {
        currentCoordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': self.color(), 'line': self.line()})
        self.sendCoordinatesIfCorrectLength()
      }
    }
  }

  self.sendToSaveCoordinates = function(saveCoordinates) {
    $.ajax({
      type: 'POST',
      url: '/remotes/' + remote.remoteId + '/write',
      data: {'coordinates': saveCoordinates}
    })
  }

  self.onMouseUp = function() {
    self.canvas.onmouseup = function(e) {
      mousedown = false
      
      self.sendCoordinates(currentCoordinates)
      self.sendToSaveCoordinates(saveCoordinates)
      
      currentCoordinates = []
    }
  }

  self.parseDrawingData = function(data) {
    var previousCoordinates = []

    if (data.length > 1) {
      $.each(data, function(index, setOfCoordinates) {
        $.each(setOfCoordinates, function(index, coordinate) {
          if (previousCoordinates.length >= 1) {
            self.remoteDraw(previousCoordinates, coordinate.x_coordinate, coordinate.y_coordinate, coordinate.color, coordinate.line)
          }

          previousCoordinates.push(coordinate)
        })
        previousCoordinates = []
      })
    }
  }

  self.drawOnLoad = function() {
    $.ajax({
      type: 'GET',
      url: '/remotes/' + remote.remoteId + '/read'
    }).done(function(data){
      self.parseDrawingData(data)
    })
  }

  self.draw = function() {
    self.drawOnLoad()
    self.onMouseDown()
    self.onMouseMove()
    self.onMouseUp()
  }

  self.draw()
} // END CANVAS CONSTRUCTOR
