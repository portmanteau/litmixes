Meteor.methods
  addSong: (data, fileName, slug) ->
    song =
      album: data.tags.album
      artist: data.tags.artist
      title: data.tags.title
      year: data.tags.year
      url: Meteor.settings.public.S3Url + Meteor.settings.public.bucketName + "/" + slug + "/" + fileName
      slug: slug

    Songs.insert(song)
