Template.mix.onCreated ->
  playerVars = {
    autoplay: 1,        # Auto-play the video on load
    controls: 0,        # Hide pause/play buttons in player
    showinfo: 0,        # Hide the video title
    modestbranding: 1,  # Hide the Youtube Logo
    playsinline: 1,
    loop: 1,            # Run the video in a loop
    fs: 0,              # Hide the full screen button
    cc_load_policy: 0,  # Hide closed captions
    iv_load_policy: 3,  # Hide the Video Annotations
    autohide: 0         # Hide video controls when playing
  }

  yt = new YTPlayer('yes', playerVars)

  Deps.autorun(()=>
    data = Router.current().data()

    if data && data.mix
      yt_id = data.mix.youtubeId

      if yt.ready()
        console.log(yt)
        yt.player.loadVideoById(yt_id)
        yt.player.mute()

        yt.player.addEventListener 'onStateChange', (event)=>
          if event.data == YT.PlayerState.ENDED
            yt.player.loadVideoById(yt_id)
            yt.player.mute()
  )
