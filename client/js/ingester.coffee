@Ingester =
  isChrome: (event) ->
    event.originalEvent.dataTransfer.items

  chromeIngest: (event) ->
    items = event.originalEvent.dataTransfer.items

    for item in items
      item = item.webkitGetAsEntry()
      if item
        @_chromeAddItem(item)

  ingest: (event) ->
    files = event.originalEvent.dataTransfer.files

    for file in files
      @_addFile(file)

  _chromeAddItem: (item, path) ->
    path = path || ""

    if item.isFile
      item.file (file) =>
        @_addFile(file)

    else if item.isDirectory
      dirReader = item.createReader()
      dirReader.readEntries (entries) ->
        for entry in entries
          @_chromeAddItem(entry, path + item.name + "/")

  _addFile: (file) ->
    jsmediatags.read(
      file,
      {
        onSuccess: (data) =>
          @_uploadFile(file).then( ->
            Meteor.call('addSong', data, file.name, Router.current().data().mix.slug)
          )
        onError: ->
          alert("Not a valid file")
      }
    )

  _uploadFile: (file) ->
    return new Promise (resolve, reject) ->
      bucket = new AWS.S3
      file_path = Router.current().data().mix.slug + "/" + file.name

      params = {
        ACL: "public-read",
        Body: file
        Bucket: Meteor.settings.public.bucketName
        ContentType: file.type,
        Key: file.name,
      }

      debugger

      bucket.putObject params, (err, data) ->
        if err
          throw new Error err
        else 
          resolve()

