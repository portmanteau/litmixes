export default class YoutubeHelper {
  constructor() {
    this.videoId = new ReactiveVar()
  }

  setVideoId(videoId) {
    this.videoId.set(videoId)
  }

  initialize() {
    var _this = this;
    var tag = document.createElement('script');

    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player;

    var playerVars = {
      autoplay: 1,        // Auto-play the video on load
      controls: 0,        // Hide pause/play buttons in player
      showinfo: 0,        // Hide the video title
      modestbranding: 1,  // Hide the Youtube Logo
      playsinline: 1,
      loop: 1,            // Run the video in a loop
      fs: 0,              // Hide the full screen button
      cc_load_policy: 0,  // Hide closed captions
      iv_load_policy: 3,  // Hide the Video Annotations
      autohide: 0,        // Hide video controls when playing
      events: {
        "onReady": function(event) {
          let player = _this.player = event.target

          Tracker.autorun(function() {
            console.log('here')
            let videoId = _this.videoId.get()

            if (videoId) {
              player.loadVideoById(videoId)
              player.playVideo()
            }
          });
        }
      }

    }

    window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
      setTimeout( () => {
        new YT.Player('player', playerVars);
      }, 1000)
    }
  }
}