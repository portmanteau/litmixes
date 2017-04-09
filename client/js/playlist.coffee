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

  load: (i) ->
    @audio.pause()
    @index = i

    try
      @audio.src = Songs.findOne({ order: @index }).url
    catch error
      if @index == 0
        @index++
        @audio.src = Songs.findOne({ order: @index }).url

    @play()

  play: ->
    if !@index
      @load(0)
      return

    @audio.play()
    $('body').addClass('playing')
    $('.song').removeClass('song--playing')
    $(".song[data-order=#{@index}]").addClass('song--playing')

  pause: ->
    @audio.pause()
    $('body').removeClass('playing')
    $('.song').removeClass('song--playing')

  _bindEvents: ->
    @audio.addEventListener('ended', @advance.bind(this))
