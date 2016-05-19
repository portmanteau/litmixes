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
    if Ingester.isChrome(event)
      Ingester.chromeIngest(event)
    else
      Ingester.ingest(event)
