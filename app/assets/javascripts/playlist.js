//class Playlist
function Playlist(source, remote){
  var self = this
  self.element = $('#playlist')
  var playlistGroup = $('#playlist_group')
  var listItems = $('#playlist li')
  var playlistClearButton = $('#clear_playlist')
  self.selectedListItem = 0

  if (authorized === 'true') {
    self.playlistItemHead = '<li class="playlist_item sortable" draggable="true"><a class="playlist-title">'
    self.playlistItemFoot = '</a><button class="btn btn-xfs btn-danger right playlist-delete">X</button></li>'
  } else {
    self.playlistItemHead = '<li class="playlist_item"><a>'
    self.playlistItemFoot = '</a></li>'
  }

  source.addEventListener("playlist_sort:" + remote.remoteId, function(event){
    self.sortPlaylist(event)
  })

  source.addEventListener("playlist_block:" + remote.remoteId, function(event){
    self.blockPlaylist(event)
  })

  source.addEventListener("playlist_add:" + remote.remoteId, function(event){
    self.addToPlaylist(event)
  })

  source.addEventListener("playlist_delete:" + remote.remoteId, function(event){
    self.deleteFromPlaylist(event)
  })

  source.addEventListener("playlist_clear:" + remote.remoteId, function(event) {
    self.clearPlaylist(event)   
  })

  // Click event for playlist items.
  self.element.on('click', '.playlist-title', function(){
    var thisSelf = $(this)
    $.ajax({
      type: 'POST',
      url: '/remotes/' + remote.remoteId + '/control',
      data: { _method:'PUT', status: 0, start_at: remote.startAt, sender_id: user, selection: $('#playlist li').index(thisSelf.parent())},
      dataType: 'JSON'
    })
  })

  // Playlist clear button click event
  playlistClearButton.on('click', function() {
    $.ajax({
      type: 'POST',
      url: '/remotes/' + remote.remoteId + '/playlist',
      data: { _method: 'DELETE', clear: $('#playlist li').length },
      dataType: 'JSON'
    })
  })

  // Playlist item delete click event
  self.element.on('click', ".playlist-delete", function(e){
    e.preventDefault()
    var index = $(this).parent().index()
    $.ajax({
      url: "/remotes/" + remote.remoteId + "/playlist",
      type: "POST",
      data: {index: index, _method: "delete"}
    })
  })

  $('#playlist_group form').on('ajax:success', function(){
    $('#playlist_url_field').val('')
  })

  // Ivoke sortable method for playlist ordered list
  $('ol.sortable').sortable()

  // Update playlist item position on drag
  $('ol.sortable').sortable().bind('sortupdate', function(e, ui) {
    playlistGroup.block()
    $.ajax({
      url: "/remotes/" + remote.remoteId + "/playlist",
      type: "POST",
      data: {old_position: ui.oldindex, new_position: ui.item.index(), _method: "patch"}
    }).done(function(){
      playlistGroup.unblock()
    })
  })

  // Update selected list item index on mousedown
  $('#playlist li').on('mousedown', function(){
    Playlist.selectedListItem = $('#playlist li').index(self)
  })

  self.refresh = function(){
    $.ajax({
      type: 'GET',
      url: '/remotes/' + remote.remoteId + "/playlist"
    }).done(function(response){
      $.each(response, function(index, item){
        self.element.append(self.playlistItemHead + item.title + self.playlistItemFoot)
      })
      self.element.sortable()
    })    
  }

  self.sortPlaylist = function(event) {
    var data = JSON.parse(event.data)

    self.element.html('')

    $.each(data.playlist, function(index, item){
      self.element.append(self.playlistItemHead + item.title + self.playlistItemFoot)
    })

    self.element.sortable()
  }

  self.blockPlaylist = function(event) {
    var data = JSON.parse(event.data)
    data = JSON.parse(data)

    if(data.block == true){
      if(data.add == true){
        playlistGroup.block({ css: { backgroundColor: '#fff', color: '#006c51', border: 'none' }, message: 'preparing playlist video' })
      } else {
        playlistGroup.block({ css: { backgroundColor: '#fff', color: '#006c51', border: 'none' }, message: 'modifying playlist' })
      }
    } else {
      playlistGroup.unblock()
    }
  }

  self.addToPlaylist = function(event) {
    var data = JSON.parse(event.data)
    self.element.append(self.playlistItemHead + JSON.parse(data).title + self.playlistItemFoot)
    self.element.sortable()
  }

  self.deleteFromPlaylist = function(event) {
    var data = JSON.parse(event.data)
    var index = parseInt(JSON.parse(data).index)

    var list_item = $('#playlist .playlist_item')[index]
    $(list_item).remove()
  }

  self.clearPlaylist = function(event) {
    $('#playlist li').remove() 
  }

  self.createPlaylist = function() {
    $.ajax({
      type: 'GET',
      url: '/remotes/' + remote.remoteId + "/playlist"
    }).done(function(response){
      $.each(response, function(index, item){
        self.element.append(self.playlistItemHead + item.title + self.playlistItemFoot)
      })
      self.element.sortable()
    })
  }

  self.createPlaylist()

} // END CONSTRUCTOR