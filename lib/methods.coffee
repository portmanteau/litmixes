Meteor.methods
  addSong: (data, file) ->
    song =
      album: data.tags.album
      artist: data.tags.artist
      title: data.tags.title
      year: data.tags.year

    Songs.insert(song)
