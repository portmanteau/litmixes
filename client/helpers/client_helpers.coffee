Template.clients.helpers
  isSelf: (sid) =>
    sid == Streamy.id()

  isWatchedClass: (sid) =>
    watchedSid = Clients.findOne({ sid: Streamy.id() }).watchedSid

    if sid == watchedSid
      return 'watched'
    else
      return ''
