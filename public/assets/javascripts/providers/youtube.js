var tag = document.createElement('script')
tag.src = "https://www.youtube.com/iframe_api"
var firstScriptTag = document.getElementsByTagName('script')[0]
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
// 3. This function creates an <iframe> (and YouTube player)
//    after the API code downloads.
var player
function onYouTubeIframeAPIReady() {
	player = new YT.Player('player', {
		height: '390',
		width: '640',
		videoId: Remote.video_id,
		playerVars: { 'autoplay': 0, 'start': Remote.start_time },
		events: {
			'onReady': onPlayerReady,
			'onStateChange': onPlayerStateChange
		}
	})
}

// 4. The API will call this function when the video player is ready.
function onPlayerReady(event) {
	// event.target.playVideo()
}

// 5. The API calls this function when the player's state changes.
//    The function indicates that when playing a video (state=1),
//    the player should play for six seconds and then stop.
var done = false

function onPlayerStateChange(event) {
	// if (send == true){
	// 	Remote.status = player.getPlayerState()
	// 	Remote.start_at = player.getCurrentTime()
	// 	Remote.update()
	// }
}

function stopVideo() {
	player.stopVideo()
}

$('#play').on('click', function(){
	Remote.status = 1
	Remote.start_at = player.getCurrentTime()
	Remote.update()
})

$('#pause').on('click', function(){
	Remote.status = 2
	Remote.start_at = player.getCurrentTime()
	Remote.update()
})