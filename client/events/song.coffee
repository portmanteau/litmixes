Template.song.events
  'click .song__play': (event) ->
    playlist.load(this.url, event.target)

  'click .song__remove': (event) ->
    title = this.title || this.fileName
    if confirm "Are you sure you want to delete #{title}?"
      Songs.remove( { _id: this._id })
