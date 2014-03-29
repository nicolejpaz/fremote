function Player(source,remote){
  var self = this
  self.element = videojs('player', {
        'plugins': {
         'chromecast': {
          enabled : true,
          appId : 'CBF3F6A9',
          namespace : 'fremote',
          title : 'Fremote',
          description : 'Take control of your videos.'
          }
        }
      }
    )

  self.addButton = function(buttonId,buttonClass,targetClass){
    var HTML = '<div id="' + buttonId + '" class="vjs-control ' + buttonClass + '" role="button" aria-live="polite" tabindex="0"></div>'
    var targetElement = $($(targetClass)[0])
    targetElement.append(HTML)
  }

  self.enableChromecast = function(){
      videojs('player', {
        'plugins': {
         'chromecast': {
          enabled : true,
          appId : 'CBF3F6A9',
          namespace : 'fremote',
          title : 'Fremote',
          description : 'Take control of your videos.'
          }
        }
      }
    )
  }

  // self.enableChromecast()

  self.addButton('resync','resync','.vjs-control-bar')

  self.resyncButtonElement = $('#resync')

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
    self.resyncButtonElement.on('click', function(){
      remote.ping()
    })
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