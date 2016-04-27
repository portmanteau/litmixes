Meteor.startup ->
  AWS.config.update
    accessKeyId: Meteor.settings.public.AWSAccessKeyId
