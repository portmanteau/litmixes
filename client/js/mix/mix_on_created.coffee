import Streamer from '/client/js/streamer'
import YouTubeHelper from '/client/js/youtube'

Template.mix.onRendered ->
  slug = Router.current().params.slug
  window.playlist = new Playlist()
  window.streamer = new Streamer(
    {
      playlist: playlist,
      slug: slug
    }
  )

  yt = new YouTubeHelper()
  yt.initialize()

  # Tracker.autorun(()=>
  #   data = Router.current().data()
  #
  #   if data && data.mix && data.mix.youtubeId
  #     yt.setVideoId(data.mix.youtubeId)
  # )

  # Deps.autorun(()=>
      # debugger
      #
      # yt_id = data.mix.youtubeId
      # yt.player.loadVideoById(yt_id)
      # yt.player.mute()
      #
      # yt.player.addEventListener 'onStateChange', (event)=>
      #   if event.data == YT.PlayerState.ENDED
      #     yt.player.loadVideoById(yt_id)
      #     yt.player.mute()
  # )
