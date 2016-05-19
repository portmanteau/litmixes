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

    Songs.upsert song, song

  deleteMp3: (song) ->
    unless song.fileName
      song.fileName = song.url.split('/').slice(-1)[0]

    console.log("DELETING: " + song.fileName)

    if Meteor.isServer
      s3 = new AWS.S3()

      s3.deleteObjectSync
        Bucket: Meteor.settings.bucketName
        Key: song.slug + "/" + song.fileName

  insertSongAfter: (movedSongId, songId) ->
    slug = Songs.findOne({_id: songId}).slug

    # Add space
    order = Songs.find({slug: slug}, {sort: {order: 1}}).map (song) ->
      song._id

    console.log("original order:" + order)
    # remove moved song
    order.splice(order.indexOf(movedSongId), 1)

    # add it at the correct index
    order.splice(order.indexOf(songId) + 1, 0, movedSongId)

    console.log("final order: " + order)

    # set thing to stuff do
    order.forEach (id, index) ->
      console.log "setting #{id} to #{index}"

      if Meteor.isClient
        $(".song[data-id=#{id}").css 'order', index

      Songs.update { _id: id}, {$set: {order: index}}, ->
        console.log('updating')
