// Override Meteor._debug to filter for custom msgs
Meteor._debug = (function (super_meteor_debug) {
  return function (error, info) {
    if (!(info && _.has(info, 'msg')))
      super_meteor_debug(error, info);
  }
})(Meteor._debug);

offset = 0;

export default class Streamer {
  constructor(options) {
    this.bindEvents();
    this.playlist = options.playlist;

    Streamy.onConnect(()=> {
      Deps.autorun(() => {
        client = Clients.findOne({ sid: Streamy.id() })

        if (client)
          this.watchedSid = client.watchedSid
          this.playOnce = true
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
          "currentTime": options.playlist.audio.currentTime,
          "localTime": Date.now()
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

      Streamy.on('play', this.playFunc.bind(this))

      Streamy.on('timeupdate', (data)=> {
        if (data.__from === Streamy.id())
          return

        if (this.playOnce) {
          this.playFunc.call(this, data)
          this.playOnce = false;
        }

        $(`[data-sid="${data.__from}"]`).find('.time').text(data.currentTime)
      })
    });
  }

  playSync(options) {
    let currentTime = options.currentTime || this.playlist.audio.currentTime;
    let lag = options.lag || 0;

    this.playlist.audio.currentTime = currentTime + lag;
    this.playlist.play()
  }

  playFunc (data) {
    if (data.__from === sid)
      return

    if (data.__from === this.watchedSid) {
      if (this.playlist.index !== data.index) {
        this.playlist.load(data.index)
      }

      this.playSync({ currentTime: data.currentTime })

      var playDate = Date.now()

      var onPlayThroughReady = ()=> {
        const loadLag = (Date.now() - playDate)/1000;
        this.playSync({ currentTime: data.currentTime, lag: loadLag })

        this.playlist.audio.removeEventListener(
          'canplaythrough',
          onPlayThroughReady
        )
      };

      this.playlist.audio.addEventListener(
        'canplaythrough',
        onPlayThroughReady
      )
    }
  }

  bindEvents() {
    document.getElementById('range').addEventListener('input', (event)=> {
      let value = event.target.value;
      let localOffset = 10*(value-50)/1000

      document.getElementById('range-reader').innerHTML = localOffset;

      this.playlist.audio.playbackRate = 1 + localOffset
    })

    let mouseup = (event)=> {
      event.target.value = 50

      document.getElementById('range-reader').innerHTML = 0;

      this.playlist.audio.playbackRate = 1;
    }

    document.getElementById('range').addEventListener('mouseup',  mouseup)
    document.getElementById('range').addEventListener('touchend',  mouseup)
  }

  updateOffset(newOffset) {
    const offsetDiff = newOffset - offset;

    this.playSync({offset: offsetDiff})

    offset = newOffset;
  }
}
