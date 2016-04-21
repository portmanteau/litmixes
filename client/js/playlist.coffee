class @Playlist
  constructor: (selector) ->
    @$el = $(selector)
    @index = 0
    @bindEvents()

  bindEvents: ->
    @$el.find('.song__play').on 'click', ->

$ ->
  $('.songs').each ->
    new Playlist(this)
