Template.mix.helpers
  hasBackground: ->
    this.mix && (this.mix.backgroundUrl || this.mix.youtubeId)
  backgroundUrl: ->
    if this.mix && this.mix.backgroundUrl
      this.mix.backgroundUrl.replace(/'/g, "\\'")

