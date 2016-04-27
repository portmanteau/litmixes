Meteor.publish("songs", (slug) ->
  Songs.find({ slug: slug })
)
