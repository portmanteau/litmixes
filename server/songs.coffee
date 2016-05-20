Meteor.publish("songs", (slug) ->
  Songs.find({ slug: slug }, {sort: { order: 1 }})
)
