@Ingester =
  isChrome: (event) ->
    event.originalEvent.dataTransfer.items

  chromeIngest: (event) ->
    items = event.originalEvent.dataTransfer.items

    j = 0
    while j < items.length
      item = items[j].webkitGetAsEntry()
      if item
        console.log(item)
      j++

  ingest: (event) ->
    # Other browser users have to upload files directly
    files = event.originalEvent.dataTransfer.files

    j = 0
    while j < files.length
      if files[j].type.match(/audio\/(mp3|mpeg)/)
        console.log(files[j])
