Meteor.startup ->
  if location.search.indexOf('dank') > -1
    $('body').addClass('dankmode')
