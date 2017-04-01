@Songs = new Mongo.Collection('songs')

Songs.before.remove (userId, doc) ->
  # It deletes these one at a time so...
  Meteor.call 'deleteMp3', doc, ->
    debugger

  Meteor.call('orderSongRemove', doc._id)

