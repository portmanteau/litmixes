isMobile = require('ismobilejs')
require("smoothscroll-polyfill").polyfill()

Template.mix.onCreated ->
  search = this.search = new ReactiveDict()

  Deps.autorun ->
    Meteor.call 'searchVideo', search.get('query'), (err, response) ->
      console.log(response)
      search.set('results', response.items)

Template.mix.helpers
  search: ->
    Template.instance().search.get('query')

  searchResults: ->
    results = Template.instance().search.get('results')

keyBounce = null
mouseBounce = null

onAction = ->
  clearTimeout(mouseBounce)

  $('.litmix').addClass('litmix--active')

  mouseBounce = setTimeout( ->
    unless isMobile.any
      $('.litmix').removeClass('litmix--active')
  , 3000)

Template.mix.events
  'click .fa-question': ->
    text = "You've reached a mix on litmix.es. Litmix.es is a web app that makes
    it easy to share mixes. There is no login with litmixes
    and no security. To save a mix, just bookmark it. To share it, just share the
    link. To add to it, you can drop an MP3 on the page, or you can search
    YouTube. It's simple. Have fun. Be nice."

    alert(text)

    event.preventDefault()

  'keyup .mix__add-song-prompt input[type=text]': (event, template) ->
    clearTimeout(keyBounce)

    keyBounce = setTimeout ->
      value = event.target.value
      search = template.search
      search.set('query', value)
    , 500

  'click .add-song': (event) ->
    $prompt = $('.mix__add-song-prompt')

    if $('body').hasClass('add-song-open')
      $prompt.one 'transitionend', ->
        $prompt.css('display', 'none')

    else
      $prompt.css('display', 'block')

      event.currentTarget.scrollIntoView({
        behavior: "smooth",
        block: "start"
      })

    setTimeout ->
      $('body').toggleClass('add-song-open')
      $('.mix__add-song-prompt input').focus()
    , 10

    event.preventDefault()

  'click .youtube-item__actions__background': (event, template) ->
    options = {
      mixId: template.data.mix._id
      videoId: this.id.videoId
      img: this.snippet.thumbnails.high.url
    }

    Meteor.call "setYouTubeBackground", options

  'mousemove .litmix': onAction
  'keydown .litmix': onAction

  'click .youtube-item__actions__add': (event, template) ->
    videoId = this.id.videoId
    title = this.snippet.title
    slug = template.data.mix.slug

    songData =
      tags:
        title: title

    Meteor.call('addSong', songData, null, slug, (err, songId) =>
      Meteor.call('uploadVideo', videoId, songId, title, slug, (err, resp) =>
        if err
          console.log(err)
          alert(err.message)
          return
      )
    )

