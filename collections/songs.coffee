@Songs = new Mongo.Collection('songs')

Songs.before.remove (userId, doc) ->
  # It deletes these one at a time so...
  if (!!doc.url)
    Meteor.call 'deleteMp3', doc

  Meteor.call('orderSongRemove', doc._id)

