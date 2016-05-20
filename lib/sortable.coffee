@SongUtils =
  updateIndexes: (selector) ->
    items = []

    $("#{selector} li").each (index, element) ->
      items.push { _id: $(element).data('id'), order: index + 1 }

    # Meteor.call 'updateSongOrder'

  initSortable: ( selector ) ->
    sortableList = $( selector )
    sortableList.sortable( 'destroy' )
    sortableList.sortable()
    sortableList.sortable().off( 'sortupdate' )
    sortableList.sortable().on 'sortupdate', () =>
      @updateIndexes selector

