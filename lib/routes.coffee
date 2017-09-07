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
    if this.ready() && Meteor.isClient
      if this.data().mix
        exports.droppables = exports.droppables || Droppable.initialize('[data-js=drop]')
        exports.playlist = exports.playlist || new Playlist()
      else
        alert("This mix does not exist!")
        this.redirect('home', {}, { query: { s: this.params.slug }})
