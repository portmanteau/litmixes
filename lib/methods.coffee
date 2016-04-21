Meteor.methods
  addSong: (data) ->
    song =
      album: data.album
      artist: data.artist
      title: data.title
      year: data.year

    Songs.insert(song)
