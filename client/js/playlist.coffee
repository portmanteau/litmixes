class @Playlist
  constructor: ->
    @audio = $('audio')[0]
    @index = 0
    @_bindEvents()

    $('.fa-pause').on('click', @pause.bind(this))
    $('.fa-play').on( 'click', @play.bind(this))
    $('.fa-fast-forward').on('click', @advance.bind(this))

  advance: ->
    @index++
    @load(@index)

  load: (index) ->
    @audio.pause()
    @index = index

    @audio.src = Songs.findOne({ order: index }).url
    @play()

    $('.song').removeClass('song--playing')
    $(".song[data-order=#{index}]").addClass('song--playing')

  play: ->
    @audio.play()
    $('body').addClass('playing')

  pause: ->
    @audio.pause()
    $('body').removeClass('playing')
    $('.song').removeClass('song--playing')

  _bindEvents: ->
    @audio.addEventListener('ended', @advance.bind(this))
