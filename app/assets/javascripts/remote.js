// class Remote
function Remote(){
  var self = this
  var endOfFormString = '<span class="input-group-btn"><button class="btn btn-edit" type="submit">Edit</button><button class="btn btn-edit btn-red" type="button">Cancel</button></span></div></form>'
  var remoteNameElement = $('#remote_name')
  var remoteDescriptionElement = $('#remote_description')
  var descriptionError = '<br><span class="error small">Please enter a description under 5000 characters</span>'
  var editRemoteTextarea = $('#edit_remote textarea')
  self.serverTime = 0
  self.status = 0
  self.startAt = 0
  self.remoteId = remote_id

  remoteNameElement.on('click', function(e) {
    if (e.target.tagName === "H3") {
      self.getNameForm($(e.target), endOfFormString)
    }
  })

  remoteDescriptionElement.on('click', function(e) {
    if (e.target.tagName === "P") {
      self.getDescriptionForm($(this).find('p'), endOfFormString)
    }
  })

  $(document).on('keypress', function(e) {
    if (e.target.id === "member_") {
      if (e.keyCode === 13) {
        e.preventDefault()
        self.addToMemberList()         
      }
    }
  })

  $(document).on('click', function(e) {
    var target = $(e.target)
    if (target[0].id === "add_members") {
      self.addToMemberList()
    } else if (target.hasClass('user-remove')) {
      e.preventDefault()
      self.removeFromMemberList(target)
    } else if (target.hasClass('user-delete')) {
      e.preventDefault()
      self.setFlagToRemoveMember(target)
    } else if (target.hasClass('user-add')) {
      e.preventDefault()
      self.removeFlagToRemoveMember(target)
    }
  })

  self.applyOrDeleteErrors = function(remaining, textarea, spans, textClass) {
    if (remaining < 0) {
      spans.addClass('error')
      spans.removeClass(textClass)
      textarea.addClass('error')
    } else {
      spans.removeClass('error')
      spans.addClass(textClass)
      textarea.removeClass('error')
    }
  }

  self.getDescriptionRemaining = function(textarea) {
    return 5000 - textarea.val().length
  }

  if (editRemoteTextarea.length !== 0) {
    var remaining = 5000 - editRemoteTextarea.val().length
    var editRemoteContainer = editRemoteTextarea.parent()

    editRemoteContainer.append('<span class="white-text small">' + remaining + ' characters remaining</span>')
    editRemoteTextarea.on('keyup', function() {
      var editCharRemaining = editRemoteTextarea.parent().find('span')
      remaining = self.getDescriptionRemaining(editRemoteTextarea)

      editCharRemaining.text(remaining + ' characters remaining.')
      self.applyOrDeleteErrors(remaining, editRemoteTextarea, editCharRemaining, 'white-text')
    })
  }

  self.addedMemberListItem = function(member) {
    return '<li><input type="hidden" name="member[]" value="' + member + '">' + member + '<button class="right btn-xfs btn-danger user-remove">X</button></li>'
  }

  self.addToMemberList = function() {
    var member = $('input#member_').val()
    if (member !== '') {
      $('#added_members').show()
      $('#added_members').find('ul').append(self.addedMemberListItem(member))
      $('input#member_').val('')
    }
  }

  self.removeFlagToRemoveMember = function(target) {
    target.parent().removeClass('to-delete')
    target.parent().find('input').remove()
    target.removeClass('user-add')
    target.addClass('user-delete')
    target.text('X')
  }

  self.setFlagToRemoveMember = function(target) {
    target.parent().addClass('to-delete')
    target.parent().append('<input type="hidden" name="delete[]" value="' + target.parent()[0].innerText.replace(/ [X]$/, '') + '" >')
    target.removeClass('user-delete')
    target.addClass('user-add')
    target.text('+')
  }

  self.removeFromMemberList = function(target) {
    if ($(target.parents()[1]).find('li').length === 1) {
      $(target.parents()[2]).hide()
    }
    target.parent().remove()
  }

  self.getNameForm = function(thisSelf, endOfFormString) {
    $(thisSelf).replaceWith('<form id="edit_remote_name" action="' + self.remoteId + '" method="PATCH"><div class="input-group input-group-sm"><input class="form-control" type="text" value="' + thisSelf.html() + '">' + endOfFormString)

    $('#remote_name form button[type="button"]').on('click', function(e) {
      $(e.target).closest('form').replaceWith(self.returnName(thisSelf.html()))
    })

    $('#remote_name form').on('submit', function(e) {
      self.updateName(e, this)
    })
  }

  self.updateName = function(e, thisSelf) {
    e.preventDefault()
    var data = $('#remote_name input').val()
    $.ajax({
      type: 'POST',
      url: '/remotes/' + self.remoteId,
      data: { _method: 'PATCH', name: data, type: 'name' }
    }).done(function(e, status, data, xhr) {
      var response_name = data.responseJSON.remote.name
      $(thisSelf).replaceWith(self.returnName(response_name))
    })
  }

  self.returnName = function(text) {
    return '<h3 class="panel-title inline">' + text + '</h3>'
  }

  self.checkDescriptionLength = function() {
    var descriptionSpans = $('#remote_description form span')
    var descriptionTextarea = $('#remote_description form textarea')
    var remaining = self.getDescriptionRemaining($('#remote_description form textarea'))

    $(descriptionSpans[1]).text(remaining + ' characters remaining.')

    self.applyOrDeleteErrors(remaining, descriptionTextarea, $(descriptionSpans[1]), 'grey-text')
  }

  self.getDescriptionForm = function(thisSelf, endOfFormString) {
    $(thisSelf).replaceWith('<form id="edit_remote_description" action="' + self.remoteId + '" method="PATCH"><div class="input-group input-group-sm"><textarea class="form-control">' + thisSelf.html() + '</textarea>' + endOfFormString)

    var descriptionForm = $('#remote_description form')
    var descriptionTextarea = $('#remote_description form textarea')

    descriptionForm.append('<span class="small grey-text">' + self.getDescriptionRemaining(descriptionTextarea) + ' characters remaining.</span>')
    descriptionForm.addClass('edit-description')
    $('#remote_description').parents().first().addClass('description-height')

    $('#remote_description form button[type="button"]').on('click', function(e) {
      $(e.target).closest('form').replaceWith(self.returnDescription(thisSelf.html()))
    })

    descriptionTextarea.on('keyup', function() {
      self.checkDescriptionLength(descriptionTextarea)
    })

    descriptionForm.on('submit', function(e) {
      self.updateDescription(e, this)
    })
  }

  self.updateDescription = function(e, thisSelf) {
    e.preventDefault()
    var data = $('#remote_description textarea').val()
    var descriptionSpans = $('#remote_description form span')
    if (data.length < 5000) {
      $.ajax({
        type: 'POST',
        url: '/remotes/' + self.remoteId,
        data: { _method: 'PATCH', description: data, type: 'description' }
      }).done(function(e, status, data, xhr) {
        var response_description = data.responseJSON.remote.description
        $(thisSelf).replaceWith(self.returnDescription(response_description))
        $('#remote_description').parents().first().removeClass('description-height')
      })
    } else {
      if (descriptionSpans.length === 2) {
        descriptionSpans.last().append(descriptionError)
      }
    }
  }

  self.returnDescription = function(text) {
    return '<p>' + text + '</p>'
  }

  self.getServerTime = function(){
    $.ajax({
      type: 'GET',
      url: '/time',
      async: false,
      dataType: 'JSON'
    }).done(function(response){
      self.serverTime = Date.parse(response.time)
      setInterval(function(){self.serverTime = self.serverTime + 1000},1000);
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