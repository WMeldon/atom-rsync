AtomRsyncView = require './atom-rsync-view'

module.exports =
  atomRsyncView: null

  activate: (state) ->
    @atomRsyncView = new AtomRsyncView(state.atomRsyncViewState)

  deactivate: ->
    @atomRsyncView.destroy()

  serialize: ->
    atomRsyncViewState: @atomRsyncView.serialize()

  configDefaults:
    uploadToRemote: true
    rsyncPath: '/usr/local/bin/rsync'
