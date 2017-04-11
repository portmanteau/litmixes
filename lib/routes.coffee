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
        Droppable.initialize('[data-js=drop]')
        exports.playlist = new Playlist()
        mix = this.data().mix

        SEO.set
          title: "litmix.es/#{mix.slug}"
          description: "A lit mix"
          og:
            image: mix.backgroundUrl

