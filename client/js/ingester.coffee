@Ingester =
  isFile: (event) ->
    event.originalEvent.dataTransfer.files.length > 0

  isChrome: (event) ->
    event.originalEvent.dataTransfer.items

  chromeIngest: (event) ->
    items = event.originalEvent.dataTransfer.items

    for item in items
      item = item.webkitGetAsEntry()
      if item
        @_chromeAddItem(item)

  ingest: (event) ->
    if @isChrome event
      @chromeIngest event
      return

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
          @_uploadFile(file).then (url) ->
            data.fileName = file.name
            Meteor.call('addSong', data, url, Router.current().data().mix.slug)
        onError: ->
          alert("Not a valid file")
      }
    )

  _uploadFile: (file) ->
    return new Promise (resolve, reject) ->
      context = { slug: Router.current().data().mix.slug }
      uploader = new Slingshot.Upload("userUpload", context)

      uploader.send file, (error, downloadUrl) ->
        if error
          console.error(error)
          alert(error)
        else
          resolve(downloadUrl)

      Deps.autorun =>
        progress = Math.round(uploader.progress() * 100)
        $('.progress-bar').width("#{progress}%")
        $('.sr-only').text("#{progress}%")
