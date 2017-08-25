Meteor.publish "clients", ->
  Clients.find({})

Streamy.onConnect (socket) =>
  Clients.insert({
    'sid': Streamy.id(socket)
  })

Streamy.onDisconnect (socket) =>
  Clients.remove({
    'sid': Streamy.id(socket)
  })

  Streamy.broadcast('__leave__', {
    'sid': Streamy.id(socket),
    'room': 'lobby'
  })
