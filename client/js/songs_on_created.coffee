onRender = ->
  new Droppable(this.firstNode)

Template.song.onRendered onRender
