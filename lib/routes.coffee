exports = this

Router.configure
  layoutTemplate: "main"

Router.route "/",
  template: "home"
  name: "home"
  subscriptions: ->
    [
      Meteor.subscribe("mixes")
    ]
  onAfterAction: ->
    if this.ready()
      $('input[name="slug"]').focus()

Router.route "/:slug",
  template: "mix"
  name: "mix"
  data: ->
    if this.ready()
      {
        mix: Mixes.findOne()
        songs: Songs.find({})
      }

  subscriptions: ->
    [
      Meteor.subscribe("mixes", this.params.slug)
      Meteor.subscribe("songs", this.params.slug)
    ]

  onAfterAction: ->
    if this.ready()
      if Meteor.isClient
        exports.droppables = exports.droppables || Droppable.initialize('[data-js=drop]')
        exports.playlist = exports.playlist || new Playlist()
        mix = this.data().mix

        SEO.set
          title: "litmix.es/#{mix.slug}"
          description: "A lit mix"
          og:
            image: mix.backgroundUrl

