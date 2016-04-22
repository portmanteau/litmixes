exports = @

Meteor.startup ->
  exports.wavesurfer = WaveSurfer.create({
    container: '#wavesurfer',
    waveColor: 'violet',
    progressColor: 'purple'
  })

  wavesurfer.on('ready', ->
    wavesurfer.play()
  )

  wavesurfer.on('play', ->
    $('body').addClass('playing')
  )

  wavesurfer.on('pause', ->
    $('body').removeClass('playing')
  )

  $('.fa-play').on('click', ->
    wavesurfer.play()
  )

  $('.fa-pause').on('click', ->
    wavesurfer.pause()
  )
