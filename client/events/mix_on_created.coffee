Template.mix.onCreated ->
  playerVars = {
    autoplay: 1,        # Auto-play the video on load
    controls: 0,        # Hide pause/play buttons in player
    showinfo: 0,        # Hide the video title
    modestbranding: 1,  # Hide the Youtube Logo
    loop: 1,            # Run the video in a loop
    fs: 0,              # Hide the full screen button
    cc_load_policy: 0,  # Hide closed captions
    iv_load_policy: 3,  # Hide the Video Annotations
    autohide: 0         # Hide video controls when playing
  }

  yt = new YTPlayer('yes', playerVars)

  Tracker.autorun(()->
    yt_id = 'VXPXkAhB6ek' # the video id for a youtube video

    if yt.ready()
      yt.player.loadVideoById(yt_id)
      yt.player.mute()
  )
