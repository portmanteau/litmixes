isMobile = require('ismobilejs')

Template.song.events
  'click .song__play': (event) ->
    if !isMobile.any
      $song = $(event.target).parents('.song')
      index = $song.data('order')

      playlist.load(index, true)

  'click .song__remove': (event) ->
    title = this.title || this.fileName
    if confirm "Are you sure you want to delete #{title}?"
      Songs.remove( { _id: this._id })
      playlist.shuffle

  'click .real-song.loaded--true': (event) ->
    if isMobile.any
      $song = $(event.currentTarget)

      if !$song.hasClass('song--playing')
        index = $song.data('order')

        playlist.load(index, true)
