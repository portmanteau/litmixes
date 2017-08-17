Template.song.events
  'click .song__play': (event) ->
    $song = $(event.target).parents('.song')
    index = $song.data('order')

    playlist.load(index)

  'click .song__remove': (event) ->
    title = this.title || this.fileName
    if confirm "Are you sure you want to delete #{title}?"
      Songs.remove( { _id: this._id })
      playlist.shuffle
