let isMobile = require('ismobilejs');
let mouseBounce = null;

class ScreenController {
  constructor() {
    this.locked = false;
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
}

export default new ScreenController();
