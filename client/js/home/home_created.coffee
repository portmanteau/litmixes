Template.home.onRendered ->
  mix = Router.current().params.query.s

  $('input[name=slug]').val(mix).click()
