@Sessions = new Mongo.Collection('sessions')

Sessions.allow
  insert: ()=>
    true
  update: ()=>
    true

