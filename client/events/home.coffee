Template.home.events
  'submit form': (event) ->
    event.preventDefault()

    slug = event.target.slug.value

    if !!Mixes.findOne({slug: slug})
      alert("taken")
    else
      id = Mixes.insert({
        slug: slug,
        createdAt: new Date(),
      })

      Router.go("mix", {slug: slug})

  'click .slug-container': (event) ->
    $('.blinker').css('display', 'none')

  'keydown input[name="slug"]': ->
    $('.blinker').css('display', 'none')


