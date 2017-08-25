Meteor.publish("sessions", (slug) ->
  Sessions.find({ slug: slug })
)
