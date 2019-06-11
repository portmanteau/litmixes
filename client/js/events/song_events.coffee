isMobile = require('ismobilejs')

Template.song.events
  'click .song__play': (event) ->
    $song = $(event.target).parents('.song')
    index = $song.data('order')

    playlist.load(index, true)

  'click .song__remove': (event) ->
    title = this.title || this.fileName
    if confirm "Are you sure you want to delete #{title}?"
      Songs.remove( { _id: this._id })
      playlist.shuffle

  'click .song': (event) ->
    if isMobile.any
      $song = $(event.target)
      index = $song.data('order')

      playlist.load(index, true)
