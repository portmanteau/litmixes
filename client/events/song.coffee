Template.song.events
  'click .song__play': (event) ->
    playlist.load(this.url, event.target)
