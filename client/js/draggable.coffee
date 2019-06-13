ScreenController = require('/client/js/screen_controller').default

class @Draggable
  constructor: (element) ->
    @$el = $(element)

    @$el.on 'dragend', (event) ->
      ScreenController.unlock()

    @$el.on 'dragstart', (event) ->
      ScreenController.lock()
      dataTransfer = event.originalEvent.dataTransfer

      dataTransfer.setData('text', this.dataset.id)
      dataTransfer.setData('id', this.dataset.id)

