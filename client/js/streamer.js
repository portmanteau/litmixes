require("range-touch")

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

      const onPlay = (event) => {
        console.log('started playing')
        console.log(event.target.currentTime)
        if (event.target.currentTime === 0)
          return

        Streamy.rooms(options.slug).emit('play', {
          "index": options.playlist.index,
          "currentTime": options.playlist.audio.currentTime,
          "localTime": Date.now()
        })

        options.playlist.audio.removeEventListener("timeupdate", onPlay)
      }

      options.playlist.audio.addEventListener("playing", ()=> {
        options.playlist.audio.addEventListener("timeupdate", onPlay)
      })

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

        if (data.__from === this.watchedSid) {
          if (this.playOnce) {
            this.playFunc.call(this, data)
          }
        }

        $(`[data-sid="${data.__from}"]`).find('.time').text(data.currentTime)
      })
    });
  }

  playSync(options) {
    let currentTime = options.currentTime || this.playlist.audio.currentTime;
    let lag = options.lag || 0;
    let browserLag =  navigator.userAgent.indexOf("Safari") > -1 ? 0.6 : 0.25;

    this.playlist.audio.currentTime = currentTime + lag + browserLag;
    this.playlist.play()
  }

  playFunc (data) {
    if (data.__from === sid)
      return

    if (data.__from === this.watchedSid) {
      this.playOnce = false;

      if (this.playlist.index !== data.index) {
        this.playlist.load(data.index)
      }

      this.playSync({
        currentTime: data.currentTime,
        lag: (Date.now() - Number(data.localTime))/1000
      })

      var onPlayThroughReady = ()=> {
        this.playSync({
          currentTime: data.currentTime,
          lag: (Date.now() - Number(data.localTime))/1000
        })

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

      this.playlist.audio.playbackRate = 1 + localOffset
    })

    let mouseup = (event)=> {
      event.target.value = 50

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
