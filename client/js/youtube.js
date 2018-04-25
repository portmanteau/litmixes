export default class YoutubeHelper {
  initialize() {
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
      videoId: "M7lc1UVf-VE",
      events: {
        "onReady": function(event) {
          event.target.playVideo()
        }
      }

    }

    window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
      setTimeout( () => {
        this.player = new YT.Player('player', playerVars);
      }, 1000)
    }
  }
}
