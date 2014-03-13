{View} = require 'atom'

module.exports =
class ChangeListView extends View
  @content: ->
    @ul class: 'list-group', =>
      @li class: 'list-item', =>
        @span class: 'status-renamed icon icon-diff-renamed', 'Using a span with an icon'
