Template.controlBar.events
  'click .fa-random': (event) ->
    $('body').toggleClass('control-bar__random')

    if $('body').hasClass('control-bar__random')
      playlist.shuffle()
    else
      playlist.unshuffle()

  'click .control-bar__timecode': (event) ->
    $('body').toggleClass('control-bar__timecode-active')
