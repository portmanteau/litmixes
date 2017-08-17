Template.controlBar.events
  'click .fa-random': (event) ->
    playlist.shuffle()
    $('body').toggleClass('control-bar__random')
