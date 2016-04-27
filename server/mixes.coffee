Meteor.publish("mixes", (slug) ->
  if slug
    Mixes.find({ slug: slug })
  else
    Mixes.find({})
)
