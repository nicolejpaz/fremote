//class
function Playlist(source){
  var self = this
  self.element = $('#playlist')
  self.playlistGroup = $('#playlist_group')
  self.listItems = $('#playlist li')
  self.playlistClearButton = $('#clear_playlist')
  self.playlistItemHead = '<li class="playlist_item sortable" draggable="true"><a class="playlist-title">'
  self.playlistItemFoot = '</a><button style="float: right;" class="btn btn-xfs btn-danger playlist-delete">X</button></li>'
  self.selectedListItem = 0

    source.addEventListener("playlist_sort:" + remote_id, function(event){
      sortPlaylist(event)
    })

    source.addEventListener("playlist_block:" + remote_id, function(event){
      blockPlaylist(event)
    })

    source.addEventListener("playlist_add:" + remote_id, function(event){
      addToPlaylist(event)
    })

    source.addEventListener("playlist_delete:" + remote_id, function(event){
      deleteFromPlaylist(event)
    })

    source.addEventListener("playlist_clear:" + remote_id, function(event) {
      clearPlaylist(event)   
    })

    // Click event for playlist items.
    self.element.on('click', '.playlist-title', function(){
      var thisSelf = $(this)
      $.ajax({
        type: 'POST',
        url: '/remotes/' + remote_id + '/control',
        data: { _method:'PUT', status: 0, start_at: remote.startAt, sender_id: user, selection: $('#playlist li').index(thisSelf.parent())},
        dataType: 'JSON'
      })
    })

    // Playlist delete button click event
    self.playlistClearButton.on('click', function() {
      $.ajax({
        type: 'POST',
        url: '/remotes/' + remote_id + '/playlist',
        data: { _method: 'DELETE', clear: $('#playlist li').length },
        dataType: 'JSON'
      })
    })

    $('#playlist_group form').on('ajax:success', function(){
      $('#playlist_url_field').val('')
    })

    // Ivoke sortable method for playlist ordered list
    $('ol.sortable').sortable()

    // Update playlist item position on drag
    $('ol.sortable').sortable().bind('sortupdate', function(e, ui) {
      self.playlistGroup.block()
      $.ajax({
        url: "/remotes/" + remote_id + "/playlist",
        type: "POST",
        data: {old_position: ui.oldindex, new_position: ui.item.index(), _method: "patch"}
      }).done(function(){
        self.playlistGroup.unblock()
      })
    })

    // Update selected list item index on mousedown
    $('#playlist li').on('mousedown', function(){
      Playlist.selectedListItem = $('#playlist li').index(self)
    })




  self.refresh = function(){
    $.ajax({
      type: 'GET',
      url: '/remotes/' + remote_id + "/playlist"
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
      self.playlistGroup.block({ css: { backgroundColor: '#006c51', color: '#fff', border: 'none' }, message: '<h3>modifying playlist</h3>' })
    } else {
      self.playlistGroup.unblock()
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
      url: '/remotes/' + remote_id + "/playlist"
    }).done(function(response){
      $.each(response, function(index, item){
        self.element.append(self.playlistItemHead + item.title + self.playlistItemFoot)
      })
      self.element.sortable()
    })
  }

} // END CONSTRUCTOR