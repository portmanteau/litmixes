import jsmediatags from "jsmediatags";
import WaveSurfer from "wavesurfer.js";

window.jsmediatags = jsmediatags;
window.WaveSurfer = WaveSurfer;

Template.body.helpers({
  songs() {
    return Songs.find({});
  },
});
