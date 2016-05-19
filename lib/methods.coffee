Meteor.methods
  addSong: (data, url, slug) ->
    song =
      album: data.tags.album
      artist: data.tags.artist
      fileName: data.fileName
      title: data.tags.title
      year: data.tags.year
      url: url
      slug: slug

    Songs.upsert(song, song)

  deleteMp3: (song) ->
    unless song.fileName
      song.fileName = song.url.split('/').slice(-1)[0]

    console.log("DELETING: " + song.fileName)

    if Meteor.isServer
      s3 = new AWS.S3()

      s3.deleteObjectSync
        Bucket: Meteor.settings.bucketName
        Key: song.slug + "/" + song.fileName
