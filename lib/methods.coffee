Meteor.methods
  addSong: (data, fileName) ->
    song =
      album: data.tags.album
      artist: data.tags.artist
      title: data.tags.title
      year: data.tags.year
      url: Meteor.settings.public.S3Url + Meteor.settings.public.bucketName + "/" + fileName

    Songs.insert(song)
