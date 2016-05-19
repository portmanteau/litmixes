class @Droppable
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
    if Ingester.isFile(event)
      Ingester.ingest(event)
    else
      console.log('song')
      dataTransfer = event.originalEvent.dataTransfer
      movedSongId = dataTransfer.getData('id')
      songId = this.dataset.id

      unless movedSongId == songId
        if songId
          Meteor.call('insertSongAfter', movedSongId, songId)
