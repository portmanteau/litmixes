Meteor.methods
  addSong: (data, url, slug) ->
    song =
      album: data.tags.album
      artist: data.tags.artist
      title: data.tags.title
      year: data.tags.year
      url: url
      slug: slug

    Songs.insert(song)
