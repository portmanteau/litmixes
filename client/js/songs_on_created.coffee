onRendered = ->
  new Droppable(this.firstNode)
  new Draggable(this.firstNode)

Template.song.onRendered onRendered
