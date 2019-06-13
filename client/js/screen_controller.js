let isMobile = require('ismobilejs');
let mouseBounce = null;

class ScreenController {
  constructor() {
    this.locked = false;
    this.bindEvents();
    this.onAction();
  }

  onAction = event => {
    clearTimeout(mouseBounce);

    $('.litmix').addClass('litmix--active');

    mouseBounce = setTimeout(() => {
      if (!isMobile.any && !this.locked) {
        $('.litmix').removeClass('litmix--active');
      }
    }, 3000);
  };

  unlock() {
    this.locked = false;
  }

  lock() {
    this.locked = true;
  }

  bindEvents() {
    $('body').on('mousemove scroll', this.onAction);
    $('*').on('dragover', this.onAction);
  }
}

export default new ScreenController();
