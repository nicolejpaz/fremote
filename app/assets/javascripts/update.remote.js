$(document).ready(function() {
  $('#remote_name h3').on('click', function() {
    getNameForm(this)
  })

  $('#remote_description p').on('click', function() {
    getDescriptionForm(this)
  })
})

function getDescriptionForm(self) {
  $(self).replaceWith('<form id="edit_remote_description" action="' + Remote.remote_id + '" method="PATCH"><textarea>' + self.innerHTML + '</textarea><button type="submit">Edit</button></form>')

  $('#remote_description form').on('submit', function(e) {
    updateDescription(e, this)
  })
}

function getNameForm(self) {
  $(self).replaceWith('<form id="edit_remote_name" action="' + Remote.remote_id + '" method="PATCH"><input value="' + self.innerHTML + '"><button type="submit">Edit</button></form>')

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
    $(self).replaceWith('<h3 class="panel-title">' + response_name + '</h3>')
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
    $(self).replaceWith('<p>' + response_description + '</p>')
  })
}