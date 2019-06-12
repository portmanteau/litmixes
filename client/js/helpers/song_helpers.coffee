Template.song.helpers
  hasUrl: ->
    String(!!this.url)

  cloudFrontUrl: ->
    playlist._toCloudfront(this.url)

