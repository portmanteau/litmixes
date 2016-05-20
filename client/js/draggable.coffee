class @Draggable
  constructor: (element) ->
    @$el = $(element)

    @$el.on 'dragstart', (event) ->
      dataTransfer = event.originalEvent.dataTransfer

      dataTransfer.effectAllowed = 'move'
      dataTransfer.setData('id', this.dataset.id)

