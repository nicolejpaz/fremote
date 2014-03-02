$(document).ready(function() {
  $('input#chat_message').on('keyup', function() {
    checkCharacterLimit(this.value)
  })
})

function checkCharacterLimit(chatValue) {
  var charactersRemaining = getCharactersRemaining(chatValue.length)
  var chatBox = $('div#chat_character_limit')
  var chatBtn = $('input.btn[name="commit"]')
  var chatForm = $('form').first()

  $('div#chat_character_limit').html(charactersRemaining + ' characters left')
  if (charactersRemaining < 0) {
    addError(chatForm, chatBox, chatBtn)
  } else {
    removeError(chatForm, chatBox, chatBtn)
  }
}

function addError(chatForm, chatBox, chatBtn) {
  chatForm.addClass('has-error')
  chatBox.addClass('error')
  chatBtn.prop('disabled', true)
}

function removeError(chatForm, chatBox, chatBtn) {
  chatForm.removeClass('has-error')
  chatBox.removeClass('error')
  chatBtn.prop('disabled', false)
}

function getCharactersRemaining(chatLength) {
  return 500 - chatLength
}