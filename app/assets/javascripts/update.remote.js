$(document).ready(function() {
  var endOfFormString = '<span class="input-group-btn"><button class="btn btn-edit" type="submit">Edit</button><button class="btn btn-edit btn-red" type="button">Cancel</button></span></div></form>'

  $('#remote_name').on('click', function(e) {
    if (e.target.tagName === "H3") {
      getNameForm($(e.target), endOfFormString)
    }
  })

  $('#remote_description').on('click', function(e) {
    if (e.target.tagName === "P") {
      getDescriptionForm($(this).find('p'), endOfFormString)
    }
  })
})

function getDescriptionForm(self, endOfFormString) {
  $(self).replaceWith('<form id="edit_remote_description" action="' + Remote.remote_id + '" method="PATCH"><div class="input-group input-group-sm"><textarea class="form-control">' + self.html() + '</textarea>' + endOfFormString)
  $('#remote_description form').addClass('edit-description')

  $('#remote_description form button[type="button"]').on('click', function(e) {
    $(e.target).closest('form').replaceWith(returnDescription(self.html()))
  })

  $('#remote_description form').on('submit', function(e) {
    updateDescription(e, this)
  })
}

$(document).on('keypress', function(e) {
  if (e.target.id === "member_") {
    if (e.keyCode === 13) {
      e.preventDefault()
      addToMemberList()         
    }
  }
})

$(document).on('click', function(e) {
  var target = $(e.target)
  if (target[0].id === "add_members") {
    addToMemberList()
  } else if (target.hasClass('user-remove')) {
    e.preventDefault()
    removeFromMemberList(target)
  } else if (target.hasClass('user-delete')) {
    e.preventDefault()
    target.parent().addClass('to-delete')
    target.parent().append('<input type="hidden" name="delete[]" value="' + target.parent()[0].innerText.replace(/ [X]$/, '') + '" >')
    target.removeClass('user-delete')
    target.addClass('user-add')
    target.text('+')
  } else if (target.hasClass('user-add')) {
    e.preventDefault()
    target.parent().removeClass('to-delete')
    target.parent().find('input').remove()
    target.removeClass('user-add')
    target.addClass('user-delete')
    target.text('X')
  }
})

function removeFromMemberList(target) {
  if ($(target.parents()[1]).find('li').length === 1) {
    $(target.parents()[2]).hide()
  }
  target.parent().remove()
}

function addToMemberList() {
  var member = $('input#member_').val()
  if (member !== '') {
    $('#added_members').show()
    $('#added_members').find('ul').append('<li><input type="hidden" name="member[]" value="' + member + '">' + member + '<button class="right btn-xfs btn-danger user-remove">X</button></li>')
    $('input#member_').val('')
  }
}

function getNameForm(self, endOfFormString) {
  $(self).replaceWith('<form id="edit_remote_name" action="' + Remote.remote_id + '" method="PATCH"><div class="input-group input-group-sm"><input class="form-control" type="text" value="' + self.html() + '">' + endOfFormString)

  $('#remote_name form button[type="button"]').on('click', function(e) {
    $(e.target).closest('form').replaceWith(returnName(self.html()))
  })

  $('#remote_name form').on('submit', function(e) {
    updateName(e, this)
  })
}

function updateName(e, self) {
  e.preventDefault()
  var data = $('#remote_name input').val()
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id,
    data: { _method: 'PATCH', name: data, type: 'name' }
  }).done(function(e, status, data, xhr) {
    var response_name = data.responseJSON.remote.name
    $(self).replaceWith(returnName(response_name))
  })
}

function updateDescription(e, self) {
  e.preventDefault()
  var data = $('#remote_description textarea').val()
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id,
    data: { _method: 'PATCH', description: data, type: 'description' }
  }).done(function(e, status, data, xhr) {
    var response_description = data.responseJSON.remote.description
    $(self).replaceWith(returnDescription(response_description))
  })
}

function returnName(text) {
  return '<h3 class="panel-title inline">' + text + '</h3>'
}

function returnDescription(text) {
  return '<p>' + text + '</p>'
}
