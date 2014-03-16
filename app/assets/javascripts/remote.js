// class Remote
function Remote(source, canvas){
  var self = this
  var endOfFormString = '<span class="input-group-btn"><button class="btn btn-edit" type="submit">Edit</button><button class="btn btn-edit btn-red" type="button">Cancel</button></span></div></form>'
  var remoteNameElement = $('#remote_name')
  var remoteDescriptionElement = $('#remote_description')
  self.serverTime = 0
  self.status = 0
  self.startAt = 0
  self.remoteId = remote_id

  remoteNameElement.on('click', function(e) {
    if (e.target.tagName === "H3") {
      getNameForm($(e.target), endOfFormString)
    }
  })

  remoteDescriptionElement.on('click', function(e) {
    if (e.target.tagName === "P") {
      getDescriptionForm($(this).find('p'), endOfFormString)
    }
  })

  self.getServerTime = function(){
    $.ajax({
      type: 'GET',
      url: '/time',
      async: false,
      dataType: 'JSON'
    }).done(function(response){
      self.serverTime = Date.parse(response.time)
      setInterval(function(){self.date = self.date + 1000},1000);
    })
  }

  self.ping = function(){
    // playlist.createPlaylist()
    $.ajax({
      type: 'GET',
      url: '/remotes/' + self.remoteId + "/ping"
    }).done(function(data){
      if (data.stream_url != undefined){
        self.player.element.src(data.stream_url)
        self.player.element.one('loadedmetadata', function(){
          self.toggle(data)
        })
      } else {
        self.toggle(data)
      }
    })
  }

  self.update = function(){
    console.log(self.startAt)
    $.ajax({
      type: 'POST',
      url: '/remotes/' + self.remoteId + '/control',
      data: { _method:'PUT', status: self.status, start_at: Math.floor(self.startAt), sender_id: user },
      dataType: 'JSON'
    })
  }

  self.pause = function(start_at){
    self.player.element.currentTime(start_at)
    self.player.element.play() // to bypass the big button mode
    self.player.element.pause()
  }

  self.play = function(start_at, updated_at){
    var offset = Math.max(0, (self.serverTime - Date.parse(updated_at)) / 1000 )
    self.player.element.currentTime(Math.floor(start_at + offset))
    self.player.element.play()
  }

  self.toggle = function(data){
    if (data.status == -1 || data.status == 2){
      self.pause(data.start_at)
    } else if (data.status == 1){
      self.play(data.start_at, data.updated_at)
    }
  }

  self.getServerTime()

} // END REMOTE CONSTRUCTOR