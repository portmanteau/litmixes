@Mixes = new Mongo.Collection('mixes')

Mixes.after.remove (userId, doc) ->
  slug = doc.slug
  Songs.remove({ slug: slug })
