$(document).ready(function() {
  var endOfFormString = '<span class="input-group-edit"><button class="btn btn-edit" type="submit">Edit</button></span></div></form>'

  $('#remote_name').on('click', function() {
    getNameForm($(this).find('h3'), endOfFormString)
  })

  $('#remote_description').on('click', function() {
    getDescriptionForm($(this).find('p'), endOfFormString)
  })
})

function getDescriptionForm(self, endOfFormString) {
  $(self).replaceWith('<form id="edit_remote_description" action="' + Remote.remote_id + '" method="PATCH"><div class="input-group input-group-sm"><textarea class="form-control">' + self.html() + '</textarea>' + endOfFormString)

  $('#remote_description form').on('submit', function(e) {
    updateDescription(e, this)
  })
}

function getNameForm(self, endOfFormString) {
  $(self).replaceWith('<form id="edit_remote_name" action="' + Remote.remote_id + '" method="PATCH"><div class="input-group input-group-sm"><input class="form-control" type="text" value="' + self.html() + '">' + endOfFormString)
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