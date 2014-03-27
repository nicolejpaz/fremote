function Player(source,remote){
  var self = this
  self.element = videojs('player')

  source.addEventListener("control:" + remote.remoteId, function(event){
    var data = JSON.parse(event.data)
    if (data.stream_url != undefined){
      self.element.src(data.stream_url)
      self.element.one('loadedmetadata', function(){
        remote.toggle(data)
      })
    } else {
      remote.toggle(data)
    }
  })

  //// Ended event is not reliable on Linux Chrome 32.  Using timeupdate instead.

  // self.element.on('ended', function(){
  //   remote.status = 0
  //   remote.update()
  // })

  // ON ENDED EVENT
  self.element.on('timeupdate',function() {
    if(this.currentTime() == this.duration()) {
      remote.status = 0
      remote.update()
    }
  })

  self.element.on('timeupdate', function(){
    self.element.loadingSpinner.hide()
  })

  self.element.ready(function(){
    remote.player = self
    remote.ping()
  })

  $(document).on('userplay', function(){
    remote.status = 1
    remote.startAt = self.element.currentTime()
    remote.update()
  })

  $(document).on('userpause', function(){
    remote.status = 2
    remote.startAt = self.element.currentTime()
    remote.update()
  })

}