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
  addImage: (data, url, slug) ->
    fileName = data.fileName

    Mixes.update({ slug: slug }, { $set: { backgroundUrl: url }})

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
    if Meteor.isServer
      Future = Npm.require('fibers/future')
      myFuture = new Future()

      unless song.fileName
        song.fileName = song.url.split('/').slice(-1)[0]

      console.log("DELETING: " + song.fileName)

      s3 = new AWS.S3()

      options =
        Bucket: Meteor.settings.bucketName
        Key: song.slug + "/" + song.fileName


      s3.deleteObject options, (err, data) =>
        if (err)
          myFuture.return(err)
        else
          myFuture.return(data)

      myFuture.wait()

  orderSongRemove: (songId) ->
    order = getOrderForSong(songId)

    order.splice(order.indexOf(songId), 1)

    setOrder(order)

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
        myFuture.return(data)

      myFuture.wait()

  uploadVideo: (videoId, title, slug) ->
    if Meteor.isServer
      ytdl = Npm.require('ytdl-core')
      Future = Npm.require('fibers/future')
      future = new Future()
      Readable = require("stream").Readable

      stream = ytdl(
        "http://www.youtube.com/watch?v=#{videoId}",
        filter: 'audioonly'
      )

      stream.on 'error', (err)=>
        console.error(err)
        future.throw(new Error(err))

      mp3Stream = ffmpeg({source: stream})
        .on 'error', (err) ->
          console.log('An error occurred: ' + err.message)
        .on 'end', ->
          console.log('Processing finished!')
        .audioCodec('libmp3lame')
        .format("mp3")
        .pipe()

      upload = new AWS.S3.ManagedUpload
        params:
          ACL: "public-read"
          Bucket: Meteor.settings.bucketName
          Key: slug + "/" + title + ".mp3"
          Body: mp3Stream

      upload.send (err, data) ->
        if err
          console.error err
        else
          console.log data

        future.return(data)

      upload.on 'httpUploadProgress', (progress) ->
        if progress.total
          percent = progress.loaded/progress.total * 100
          Streamy.broadcast(
            'uploadPercentage', {
              percent: Math.floor(percent)
              slug: slug
            }
          )

      future.wait()

