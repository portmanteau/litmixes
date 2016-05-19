@Songs = new Mongo.Collection('songs')

Songs.allow
  remove: (userId, doc) ->
    true

Songs.after.remove (userId, doc) ->
  # It deletes these one at a time so...
  Meteor.call('deleteMp3', doc)
