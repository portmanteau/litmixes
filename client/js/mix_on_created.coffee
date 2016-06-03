Template.mix.onRendered ->
  $('.drop-area').click ->
    $('body').toggleClass('add-song-open')
