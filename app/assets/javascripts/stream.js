function Stream(){
  var self = this
  var alertClosed = $('div.alert-danger')
  self.source = new EventSource(remote_id + '/stream')

  if (self.source.readyState === 0) {
    // Connecting
    alertClosed.hide()
  }

  window.onunload = function() {
    self.source.close()
  }

  self.source.onopen = function() {
    // Connected
    alertClosed.hide()
  }

  self.source.onerror = function() {
    // Disconnected
    alertClosed.show()
  }

} // END STREAM CONSTRUCTOR