Meteor.publish("rooms", (slug) ->
  Streamy.Rooms.model.find({ name: slug })
)
