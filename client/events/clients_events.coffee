Template.clients.events
  'click .client': (event)->
    sid = event.target.dataset['sid']

    clientId = Clients.findOne({ sid: Streamy.id() })._id

    Clients.update( { _id: clientId }, { $set: {
      watchedSid: sid
    }})
