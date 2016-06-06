getOrderForSong = (songId) ->
  slug = Songs.findOne({_id: songId}).slug

  # get order
  Songs.find({slug: slug}, {sort: {order: 1}}).map (song) ->
    song._id

setOrder = (order) ->
  order.forEach (id, index) ->
    console.log "setting #{id} to #{index}"

    if Meteor.isClient
      $(".song[data-id='#{id}'").css 'order', index

    Songs.update { _id: id}, {$set: {order: index}}, ->
      console.log('updating')

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

    Songs.upsert song, song, ->
      songId = arguments[1].insertedId

      if !!songId
        Meteor.call('orderSongBottom', songId)

  deleteMp3: (song) ->
    unless song.fileName
      song.fileName = song.url.split('/').slice(-1)[0]

    console.log("DELETING: " + song.fileName)

    if Meteor.isServer
      s3 = new AWS.S3()

      s3.deleteObjectSync
        Bucket: Meteor.settings.bucketName
        Key: song.slug + "/" + song.fileName

  orderSongTop: (songId) ->
    order = getOrderForSong(songId)

    if order.indexOf(songId)
      order.splice(order.indexOf(songId), 1)

    order.unshift songId

    setOrder(order)

  orderSongBottom: (songId) ->
    order = getOrderForSong(songId)

    if order.indexOf(songId)
      order.splice(order.indexOf(songId), 1)

    order.push songId

    setOrder(order)

  orderSongAfter: (movedSongId, songId) ->
    order = getOrderForSong(songId)

    # move song
    order.splice(order.indexOf(movedSongId), 1)

    order.splice(order.indexOf(songId) + 1, 0, movedSongId)

    # set order
    setOrder(order)

  searchVideo: (search) ->
    if Meteor.isServer
      Future = Npm.require('fibers/future')
      myFuture = new Future()

      YoutubeApi.search.list
        part: "snippet",
        type: "video",
        maxResults: 5,
        q: search,
      , (err, data) ->
        console.log(err, data)
        myFuture.return(data)

      myFuture.wait()

  uploadVideo: (videoId, title, slug) ->
    if Meteor.isServer
      ytdl = Npm.require('ytdl-core')
      Future = Npm.require('fibers/future')

      stream = ytdl(
        "http://www.youtube.com/watch?v=#{videoId}",
        filter: 'audioonly'
      )

      future = new Future()

      upload = new AWS.S3.ManagedUpload
        params:
          ACL: "public-read"
          Bucket: Meteor.settings.bucketName
          Key: slug + "/" + title + ".mp4"
          Body: stream

      upload.send (err, data) ->
        if err
          console.error err
        else
          console.log data

        future.return(data)

      future.wait()
