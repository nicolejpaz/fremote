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
  return '<h3 class="panel-title">' + text + '</h3>'
}

function returnDescription(text) {
  return '<p>' + text + '</p>'
}
