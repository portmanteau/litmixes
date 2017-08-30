Meteor.startup( () => {
  window.addEventListener('keydown', (event)=> {
    if(event.target.tagName === "INPUT")
      return

    if(event.code == "Space") {
      playlist.playToggle()
    } else if(event.code == "ArrowRight") {
      playlist.advance()
    } else if(event.code == "ArrowLeft") {
      playlist.retreat()
    }
  });
})
