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

Template.mix.events
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

    setTimeout ->
      $('body').toggleClass('add-song-open')
    , 10

   'click .youtube-item__actions__add': (event, template) ->
     videoId = this.id.videoId
     title = this.snippet.title
     slug = template.data.mix.slug

     Meteor.call('uploadVideo', this.id.videoId, title, slug, (err, resp) ->
       console.log(arguments)

       if err
         return

       data =
         tags:
           title: title

       # ?? I have no idea why it's sometimes key and sometimes Key
       if resp.key
         data.fileName = resp.key.split('/')[1]
       else
         data.fileName = resp.Key.split('/')[1]

       Meteor.call('addSong', data, resp.Location, slug)
     )

