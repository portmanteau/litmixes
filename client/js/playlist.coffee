import { shuffle } from 'lodash'

class @Playlist
  constructor: ->
    @audio = $('audio')[0]
    @index = 0
    @_bindEvents()

    $('.fa-pause').on('click', @pause.bind(this))
    $('.fa-play').on( 'click', @play.bind(this))
    $('.fa-step-forward').on('click', @advance.bind(this))
    $('.fa-step-backward').on('click', @retreat.bind(this))

  advance: ->
    @index++
    @load(@index)

  retreat: ->
    @index--
    @load(@index)

  loadIndex: ->
    loadIndex = @index

    if $('body').hasClass('control-bar__random')
      loadIndex = @shuffleOrder[@index]

    loadIndex

  load: (i) ->
    @audio.pause()
    @index = i

    try
      @audio.src = Songs.findOne({ order: @loadIndex()}).url
    catch error
      if @index < Songs.find().count()
        @index++
      else
        @index = 0

      return this.load(@index)

    @play()

  play: ->
    if !@audio.src
      @load(0)
      return

    @audio.play()
    $('body').addClass('playing')
    $('.song').removeClass('song--playing')
    $(".song[data-order=#{@loadIndex()}]").addClass('song--playing')

  pause: ->
    @audio.pause()
    $('body').removeClass('playing')
    $('.song').removeClass('song--playing')

  shuffle: ->
    @shuffleOrder = []
    standardOrder = Array.apply(null, Array(Songs.find().count())).map (_undef, index) ->
      return index

    while (standardOrder.length > 0)
      index = Math.floor(Math.random() * standardOrder.length)
      @shuffleOrder = @shuffleOrder.concat( standardOrder.splice(index, 1) )

    @shuffleOrder

  _bindEvents: ->
    @audio.addEventListener('ended', @advance.bind(this), false)
