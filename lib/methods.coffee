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
  addVideo: (url, slug) ->
    Mixes.update({ slug: slug }, { $set: { videoSrc: url }})

  addImage: (data, url, slug) ->
    Mixes.update({ slug: slug }, { $set: { backgroundUrl: url }})

  addSong: (data, url, slug) ->
    if Meteor.isServer
      Future = require('fibers/future')
      myFuture = new Future()

      song =
        album: data.tags.album
        artist: data.tags.artist
        fileName: data.fileName
        title: data.tags.title
        year: data.tags.year
        url: url
        slug: slug

      myFuture.return(
        Songs.insert song, ->
          songId = arguments[1].insertedId

          if !!songId
            Meteor.call('orderSongBottom', songId)
      )

      if Meteor.isClient
        playlist.shuffle()

      myFuture.wait()

  updateSongUrl: (songId, url) ->
    Songs.update { _id: songId }, { $set: {url: url} }

  deleteMp3: (song) ->
    if Meteor.isServer
      Future = require('fibers/future')
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
      Future = require('fibers/future')
      myFuture = new Future()

      YoutubeApi.search.list
        part: "snippet",
        type: "video",
        maxResults: 5,
        q: search,
      , (err, data) ->
        if (err)
          myFuture.return(err)
        else
          myFuture.return(data)

      myFuture.wait()

  uploadVideo: (videoId, songId, title, slug) ->
    if Meteor.isServer
      ytdl = require('ytdl-core')
      Future = require('fibers/future')
      future = new Future()
      Readable = require("stream").Readable
      ytVideo = {}

      progressFunction = (progress) ->
        data = {
          loaded: 1,
          total: 100,
          message: "Loading...",
          slug: slug
        }

        _.extend(data, progress)

        console.log(data)
        percent = Math.floor(
          100*(Number(data.loaded)/Number(data.total))
       )
        console.log(percent)

        Streamy.broadcast(
          'uploadPercentage', {
            message: progress.message
            percent: percent
            songId: songId
            slug: slug
          }
        )

      ytStream = ytdl(
        "http://www.youtube.com/watch?v=#{videoId}",
        filter: 'audioonly'
      )

      ytStream.on 'error', (err)=>
        console.error(err)
        future.throw(new Error(err))

      ytStream.on 'progress', (event) =>
        console.log('ytProgress')
        console.log(event)

      ytStream.on 'info', (event) =>
        ytVideo.length_seconds = event.length_seconds

      mp3Stream = ffmpeg({source: ytStream})
        .on 'error', (err) ->
          console.log('An error occurred: ' + err.message)
        .on 'end', ->
          console.log('Processing finished!')
        .on 'progress', (event) ->
          console.log('mp3Event')
          console.log(event)
          loadedSeconds = event.timemark.split(':')[1]*60
          totalSeconds = ytVideo.length_seconds
          progress = {
            loaded: loadedSeconds
            total: totalSeconds
            message: "Compressing Audio"
          }

          progressFunction(progress)
        .audioCodec('libmp3lame')
        .format("mp3")
        .pipe()

      uploadStream = new AWS.S3.ManagedUpload
        params:
          ACL: "public-read"
          Bucket: Meteor.settings.bucketName
          Key: slug + "/" + title + ".mp3"
          Body: mp3Stream

      uploadStream.send (err, data) ->
        if err
          console.error err
        else
          console.log data

        future.return(data)

      uploadStream.on 'httpUploadProgress', (progress) =>
        console.log('uploadEvent')
        if progress.total
          ytVideo.totalBytes = progress.total

        progress = {
          loaded: progress.loaded
          total: ytVideo.totalBytes
          message: "Uploading Audio"
        }

        if progress.loaded && ytVideo.totalBytes
          progressFunction(progress)

      future.wait()

