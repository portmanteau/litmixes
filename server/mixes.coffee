Meteor.publish("mixes", (slug) ->
  debugger
  if slug
    Mixes.find({ slug: slug })
  else
    Mixes.find({})
)
