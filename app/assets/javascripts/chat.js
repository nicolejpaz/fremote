// class Chat
function Chat(source,remote){
  var self = this
  var chatInput = $('input#chat_message')
  var chatTableBody = $('#chat_table_body')
  var characterLimitElement = $('div#chat_character_limit')

  chatInput.on('keyup', function() {
    self.checkCharacterLimit(this.value)
  })

  source.addEventListener("chat:" + remote.remoteId, function(event){
    self.sendChatMessage(event)
  })

  self.checkCharacterLimit = function(chatValue) {
    var charactersRemaining = self.getCharactersRemaining(chatValue.length)
    var chatBox = $('div#chat_character_limit')
    var chatBtn = $('input.btn[name="commit"]')
    var chatForm = $('form').first()

    characterLimitELement.html(charactersRemaining + ' characters left')

    if (charactersRemaining < 0) {
      self.addError(chatForm, chatBox, chatBtn)
    } else {
      self.removeError(chatForm, chatBox, chatBtn)
    }

  }

  self.addError = function(chatForm, chatBox, chatBtn) {
    chatForm.addClass('has-error')
    chatBox.addClass('error')
    chatBtn.prop('disabled', true)
  }

  self.removeError = function(chatForm, chatBox, chatBtn) {
    chatForm.removeClass('has-error')
    chatBox.removeClass('error')
    chatBtn.prop('disabled', false)
  }

  self.getCharactersRemaining = function(chatLength) {
    return 500 - chatLength
  }

  self.sendChatMessage = function(event) {
    var data = JSON.parse(event.data)
    chatInput.val('')
    chatTableBody.prepend('<tr>' + '<td>' + data.message + '</td>' + '<td class="grey-text">' + data.name + '</td>' + '</tr>')
  }

} // END CHAT CONSTRUCTOR



// $(document).ready(function() {
//   $('input#chat_message').on('keyup', function() {
//     checkCharacterLimit(this.value)
//   })
// })

// function checkCharacterLimit(chatValue) {
//   var charactersRemaining = getCharactersRemaining(chatValue.length)
//   var chatBox = $('div#chat_character_limit')
//   var chatBtn = $('input.btn[name="commit"]')
//   var chatForm = $('form').first()

//   $('div#chat_character_limit').html(charactersRemaining + ' characters left')
//   if (charactersRemaining < 0) {
//     addError(chatForm, chatBox, chatBtn)
//   } else {
//     removeError(chatForm, chatBox, chatBtn)
//   }
// }

// function addError(chatForm, chatBox, chatBtn) {
//   chatForm.addClass('has-error')
//   chatBox.addClass('error')
//   chatBtn.prop('disabled', true)
// }

// function removeError(chatForm, chatBox, chatBtn) {
//   chatForm.removeClass('has-error')
//   chatBox.removeClass('error')
//   chatBtn.prop('disabled', false)
// }

// function getCharactersRemaining(chatLength) {
//   return 500 - chatLength
// }

// function sendChatMessage(event) {
//   var data = JSON.parse(event.data)
//   $('#chat_message').val('')
//   $('#chat_table_body').prepend('<tr>' + '<td>' + data.message + '</td>' + '<td class="grey-text">' + data.name + '</td>' + '</tr>')
// }