import Streamer from '/client/js/streamer';
import YouTubeHelper from '/client/js/youtube';

Template.mix.onRendered(function() {
  const {slug} = Router.current().params;
  window.playlist = new Playlist();
  window.streamer = new Streamer({
    playlist,
    slug,
  });

  const yt = new YouTubeHelper();
  yt.initialize();

  return Tracker.autorun(() => {
    const data = Router.current().data();

    if (data && data.mix && data.mix.youtubeId) {
      return yt.setVideoId(data.mix.youtubeId);
    }
  });
});
