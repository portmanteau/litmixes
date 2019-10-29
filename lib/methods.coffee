getOrderForSong = (songId) ->
  slug = Songs.findOne({_id: songId}).slug

  # get order
  Songs.find({slug: slug}, {sort: {order: 1}}).map (song) ->
    song._id

setOrder = (order) ->
  order.forEach (id, index) ->
    console.log "setting #{id} to #{index}"

    if Meteor.isClient
      $(".song[data-id='#{id}']").css 'order', index

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

      count = Songs.find({ slug: slug }).count() + 1

      song =
        album: data.tags.album
        artist: data.tags.artist
        fileName: data.fileName
        title: data.tags.title
        year: data.tags.year
        url: url
        slug: slug
        order: count


      myFuture.return(
        Songs.insert song
      )

      if Meteor.isClient
        playlist.shuffle()

      myFuture.wait()

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
      YouTube = require("youtube-node")
      youTube = new YouTube()
      youTube.setKey(Meteor.settings.google)
      youTube.addParam('type', 'video')

      youTube.search search, 10, (error, result) ->
        if (error)
          myFuture.return(error)
        else
          # console.log(result)
          myFuture.return(result)

      myFuture.wait()

  uploadVideo: (videoId, songId, title, slug) ->
    if Meteor.isServer
      ytdl = require('ytdl-core')
      Readable = require("stream").Readable
      ytVideo = {}

      progressFunction = (progress) ->
        percent = Math.floor(
          100*(Number(progress.loaded)/Number(progress.total))
        )

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
        Songs.remove { _id: songId }

      ytStream.on 'progress', (event) =>
        # console.log('ytProgress')
        # console.log(event)

      ytStream.on 'info', (event) =>
        console.log("Info")
        # console.log(event)
        ytVideo.length_seconds = event.player_response.videoDetails.lengthSeconds
        # console.log(ytVideo)

      mp3Stream = ffmpeg({source: ytStream})
        .on 'error', (err) ->
          console.log('An error occurred: ' + err.message)
          Songs.remove { _id: songId }
        .on 'end', ->
          console.log('Processing finished!')
        .on 'progress', (event) ->
          # console.log('mp3Event')
          # console.log(event)
          times = event.timemark.split(':')
          loadedSeconds = parseInt(times[2])
          loadedSeconds += parseInt(times[1] * 60)
          loadedSeconds += parseInt(times[0]) * 60 * 60

          console.log(times)
          console.log(loadedSeconds)
          totalSeconds = ytVideo.length_seconds
          progress = {
            loaded: loadedSeconds
            total: totalSeconds
            percent: loadedSeconds/totalSeconds * 100
            message: "Compressing Audio"
          }

          # console.log("here")
          console.log(event)

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

      uploadStream.send Meteor.bindEnvironment((err, data) ->
        if err
          # remove song
          Songs.remove { _id: songId }
          console.error err
        else
          # console.log data
          Songs.update { _id: songId }, { $set: {url: data.Location} }
      )

      uploadStream.on 'httpUploadProgress', (progress) =>
        # console.log('uploadEvent')
        if progress.total
          ytVideo.totalBytes = progress.total

        progress = {
          loaded: progress.loaded
          total: ytVideo.totalBytes
          message: "Uploading Audio"
        }

        if progress.loaded && ytVideo.totalBytes
          progressFunction(progress)
