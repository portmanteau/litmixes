class Droppable
  @initialize: (selector) ->
    $(selector).each ->
      new Droppable(this)

  constructor: (element) ->
    @$el = $(element)
    @$el.on 'drop dragover dragleave', (event) ->
      event.preventDefault()
      event.stopPropagation()

    @$el.on 'dragover', (event) ->
      $(this).addClass('dragover')

    @$el.on 'dragleave drop', (event) ->
      $(this).removeClass('dragover')

    @$el.on 'drop', @onDrop

  onDrop: (event) ->
    if event.originalEvent.dataTransfer.items
      # For chrome users folder upload is supported
      items = event.originalEvent.dataTransfer.items
      j = 0
      while j < items.length
        item = items[j].webkitGetAsEntry()
        if item
          console.log(item)
          # traverseFileTree item
        j++
    else
      # Other browser users have to upload files directly
      files = event.originalEvent.dataTransfer.files
      j = 0
      while j < files.length
        if files[j].type.match(/audio\/(mp3|mpeg)/)
          console.log(files[j])
        #   getID3Data files[j], (song) ->
        #     allTracks.push song
        #     playlist.push song
        #     $('#list').append $(returnTrackHTML(song, playlist.length - 1))
        #     return
        # j++

$ ->
  Droppable.initialize('[data-js="drop"]')
