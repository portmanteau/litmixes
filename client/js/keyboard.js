Meteor.startup(() => {
  window.addEventListener('keydown', event => {
    if (event.target.tagName === 'INPUT') return;

    if (event.code == 'Space') {
      playlist.playToggle();
      event.preventDefault();
    } else if (event.code == 'ArrowRight') {
      playlist.advance();
      event.preventDefault();
    } else if (event.code == 'ArrowLeft') {
      playlist.retreat();
      event.preventDefault();
    }
  });
});
