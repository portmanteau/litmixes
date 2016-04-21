exports = this

class Playlist
  constructor: ->
    @audio = $('audio')[0]

    $('.fa-pause').on('click', @pause.bind(this))
    $('.fa-play').on('click', @play.bind(this))

  load: (url, target) ->
    @audio.src = url
    @play()

    $('.song--playing').removeClass('song--playing')
    $(target).addClass('song--playing')

  play: ->
    @audio.play()
    $('body').addClass('playing')

  pause: ->
    @audio.pause()
    $('body').removeClass('playing')

$ ->
  exports.playlist = new Playlist()
