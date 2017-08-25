// Override Meteor._debug to filter for custom msgs
Meteor._debug = (function (super_meteor_debug) {
  return function (error, info) {
    if (!(info && _.has(info, 'msg')))
      super_meteor_debug(error, info);
  }
})(Meteor._debug);

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
            "currentTime": event.target.currentTime,
            "localTime": Date.now()
          }
        )
      });

      options.playlist.audio.addEventListener("pause", function(event) {
        Streamy.rooms(options.slug).emit('pause', {})
      });

      const onPlay = () => {
        Streamy.rooms(options.slug).emit('play', {
          "index": options.playlist.index,
          "currentTime": options.playlist.audio.currentTime
        })
      }

      options.playlist.audio.addEventListener("play", onPlay)
      options.playlist.audio.addEventListener("canplaythrough", ()=> {
        if (!this.watchedSid)
          onPlay.apply(this, arguments)
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

        if (data.__from === this.watchedSid) {
          if (options.playlist.index !== data.index) {
            options.playlist.load(data.index)
          }

          options.playlist.audio.currentTime = data.currentTime
          options.playlist.play()

          var playDate = Date.now()

          var onPlayThroughReady = ()=> {
            const timeDiff = (Date.now() - playDate)/1000;
            const finalTime = Number(data.currentTime) + timeDiff

            console.log("Adding " + timeDiff)
            console.log("Final time " + finalTime)
            options.playlist.audio.currentTime = finalTime;
            options.playlist.play()
            console.log(options.playlist.audio.currentTime)

            options.playlist.audio.removeEventListener(
              'canplaythrough',
              onPlayThroughReady
            )
          };

          options.playlist.audio.addEventListener(
            'canplaythrough',
            onPlayThroughReady
          )
        }
      });

      Streamy.on('timeupdate', (data)=> {
        if (data.__from === Streamy.id())
          return

        $(`[data-sid="${data.__from}"]`).find('.time').text(data.currentTime)
      })
    });
  }
}
