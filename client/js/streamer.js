export default class Streamer {
  constructor(options) {
    Streamy.onConnect(()=> {
      Deps.autorun(() => {
        client = Clients.findOne({ sid: Streamy.id() })

        if (client)
          this.watchedSid = client.watchedSid
      });

      Streamy.join(options.slug)
      sid = Streamy.id()
      masterTime = 0
      watchInterval = null

      options.playlist.audio.addEventListener("timeupdate", function(event) {
        Streamy.rooms(options.slug).emit(
          'timeupdate',
          {
            "index": options.playlist.index,
            "timeStamp": event.timeStamp,
            "localTime": Date.now()
          }
        )
      });

      options.playlist.audio.addEventListener("pause", function(event) {
        Streamy.rooms(options.slug).emit('pause', {})
      });

      options.playlist.audio.addEventListener("play", function(event) {
        Streamy.rooms(options.slug).emit('play', {
          "index": options.playlist.index
        })
      });

      Streamy.on('pause', (data)=> {
        if (data.__from === sid)
          return

        if (data.__from === this.watchedSid) {
          options.playlist.pause()
        }
      });

      Streamy.on('play', (data)=> {
        if (data.__from === sid)
          return

        if (data.__from === this.watchedSid)
          if (options.playlist.index !== data.index) {
            options.playlist.load(data.index)
          }

          options.playlist.play()
      });

      Streamy.on('timeupdate', (data)=> {
        if (data.__from === Streamy.id())
          return

        if (data.__from === this.watchedSid) {
          masterTime = data
        }

        $(`[data-sid="${data.__from}"]`).find('.time').html(data.timeStamp)
      })
    });
  }
}
