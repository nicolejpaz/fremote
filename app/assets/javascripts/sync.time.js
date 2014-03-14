function synchronizeTime() {
  // Synchronize time with server.  Use this instead of Date.now().
  $.ajax({
    type: 'GET',
    url: '/time',
    async: false,
    dataType: 'JSON'
  }).done(function(response){
    Remote.date = Date.parse(response.time)
    setInterval(function(){Remote.date = Remote.date + 1000},1000);
  })
}