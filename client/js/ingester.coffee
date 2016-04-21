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
    jsmediatags.read file, onSuccess: @_addSong, onError: ->
      alert("Not a valid file")

  _addSong: (data) ->
      console.log(data.tags)
      Meteor.call('addSong', data.tags)
