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
		playerVars: { 'autoplay': 0, 'start': Remote.start_time, 'controls': 0 },
		events: {
			'onReady': onPlayerReady,
			'onStateChange': onPlayerStateChange
		}
	})
}


function updateSlider(){
	var value = parseInt(Math.ceil(player.getCurrentTime()))
	$('#slider').val(value)
}

var sliderTimer
// 4. The API will call this function when the video player is ready.
function onPlayerReady(event) {
	// event.target.playVideo()
	var playerSlider = document.getElementById('slider')
	playerSlider.setAttribute("max", player.getDuration())
	sliderTimer = setInterval( "updateSlider()", 1000 )
	console.log('timer started')
}

// 5. The API calls this function when the player's state changes.
//    The function indicates that when playing a video (state=1),
//    the player should play for six seconds and then stop.
var done = false

function onPlayerStateChange(event) {
	var playerSlider = document.getElementById('slider')
	playerSlider.setAttribute("max", player.getDuration())
}

function stopVideo() {
	player.stopVideo()
}


$('#play').on('click', function(){
	console.log('play button clicked')
	var currentStatus = player.getPlayerState()
	if (currentStatus !=1){
		Remote.status = 1
	} else if (currentStatus == 1){
		Remote.status = 2
	}
	Remote.start_at = player.getCurrentTime()
	Remote.update()
})

$('#pause').on('click', function(){
	console.log('pause button clicked')
	Remote.status = 2
	Remote.start_at = player.getCurrentTime()
	Remote.update()
})

$('#slider').mousedown(function(){
	console.log('mousedown')
	clearInterval(sliderTimer)
})

$('#slider').mouseup(function(){
	console.log('mouseup')
	var sliderTimer = setInterval( "updateSlider()", 1000 )
	Remote.start_at = $('#slider').val()
	Remote.update()
})