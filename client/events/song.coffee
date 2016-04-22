Template.song.events
  'click .song': (event) ->
    wavesurfer.load(this.url)

