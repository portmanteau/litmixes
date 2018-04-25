Meteor.methods
  setYouTubeBackground: (options) =>
    Mixes.update(
      { _id: options.mixId },
      { $set: {
        backgroundUrl: options.img,
        youtubeId: options.videoId }
      }
    )
