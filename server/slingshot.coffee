Slingshot.createDirective "userUpload", Slingshot.S3Storage, 
  bucket: Meteor.settings.bucketName
  acl: "public-read"
  authorize: ->
    true
  key: (file, context) ->
    context.slug + "/" +  file.name
