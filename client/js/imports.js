import jsmediatags from "jsmediatags";

window.jsmediatags = jsmediatags;

Template.body.helpers({
  songs() {
    return Songs.find({});
  },
});
