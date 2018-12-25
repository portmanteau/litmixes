import Streamer from './streamer';
let timecodeInterval = null;

this.Playlist = class Playlist {
  constructor(options) {
    this.audio = $('audio')[0];
    this.index = 0;
    this._bindEvents();

    $('.fa-pause').on('click', this.pause.bind(this));
    $('.fa-play').on('click', this.play.bind(this));
    $('.fa-step-forward').on('click', this.advance.bind(this));
    $('.fa-step-backward').on('click', this.retreat.bind(this));

    if (window.location.search.indexOf('autoplay') > -1) {
      setTimeout(() => {
        return $('.control-bar .fa-play').click();
      }, 1000);
    }
  }

  advance() {
    this.index++;
    return this.load(this.index);
  }

  retreat() {
    this.index--;
    return this.load(this.index);
  }

  loadIndex() {
    let loadIndex = this.index;

    if ($('body').hasClass('control-bar__random')) {
      loadIndex = this.shuffleOrder[this.index];
    }

    return loadIndex;
  }

  load(i, literal) {
    this.audio.pause();
    this.index = i;

    if (literal && $('body').hasClass('control-bar__random')) {
      this.index = this.shuffleOrder.indexOf(i);
    }

    try {
      this.audio.src = Songs.findOne({order: this.loadIndex()}).url;
    } catch (error) {
      if (this.index < Songs.find().count()) {
        this.index++;
      } else {
        this.shuffle();
        this.index = 0;
      }

      return this.load(this.index);
    }

    return this.play();
  }

  play() {
    if (!this.audio.src) {
      this.load(0);
      return;
    }

    this.audio.play();
    $('body').addClass('playing');
    $('.song').removeClass('song--playing');
    $(`.song[data-order=${this.loadIndex()}]`).addClass('song--playing');

    return (timecodeInterval = setInterval(() => {
      return $('.control-bar__timecode').text(
        Math.floor(this.audio.currentTime),
      );
    }));
  }

  playToggle() {
    if ($('body').hasClass('playing')) {
      return this.pause();
    } else {
      return this.play();
    }
  }

  pause() {
    this.audio.pause();
    $('body').removeClass('playing');
    $('.song').removeClass('song--playing');

    return clearInterval(timecodeInterval);
  }

  shuffle() {
    let index;
    this.shuffleOrder = [];
    const standardOrder = Array.apply(null, Array(Songs.find().count())).map(
      (_undef, index) => {
        return index;
      },
    );

    while (standardOrder.length > 0) {
      index = Math.floor(Math.random() * standardOrder.length);
      this.shuffleOrder = this.shuffleOrder.concat(
        standardOrder.splice(index, 1),
      );
    }

    this.index = this.shuffleOrder.indexOf(this.index);

    return this.shuffleOrder;
  }

  unshuffle() {
    return (this.index = this.shuffleOrder.indexOf(this.index));
  }

  _bindEvents() {
    return this.audio.addEventListener('ended', this.advance.bind(this), false);
  }
};
