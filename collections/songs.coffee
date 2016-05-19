@Songs = new Mongo.Collection('songs')
Songs.after.remove (userId, doc) ->
  # It deletes these one at a time so...
  Meteor.call('deleteMp3', doc)
