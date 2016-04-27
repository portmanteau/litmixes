class @Playlist
  constructor: ->
    @audio = $('audio')[0]

    $('.fa-pause').on('click', @pause.bind(this))
    $('.fa-play').on('click', @play.bind(this))

  load: (url, target) ->
    @audio.src = url
    @play()

    $('.song').removeClass('song--playing')
    @_$songElementFor(target).addClass('song--playing')

  play: ->
    @audio.play()
    $('body').addClass('playing')

  pause: ->
    @audio.pause()
    $('body').removeClass('playing')
    $('.song').removeClass('song--playing')

  _$songElementFor: (target) ->
    $(target).parents('.song')
