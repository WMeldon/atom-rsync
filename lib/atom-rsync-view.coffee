{EditorView, View} = require 'atom'

path = require 'path'
Rsync = require './rsync-model'
ChangeListView = require './change-list-view'

module.exports =
class AtomRsyncView extends View
  @content: ->
    @div class: 'atom-rsync overlay from-top padded', =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span outlet: "title"
          @div class: "btn-toolbar pull-right", outlet: 'toolbar', =>
            @div class: "btn-group", =>
              @button outlet: "localButton", class: "btn", "Local"
              @button outlet: "remoteButton", class: "btn", "Remote"
        @div class: "panel-body padded", =>
          @div outlet: 'rsyncForm', =>
            @subview 'hostEditor', new EditorView(mini:true, placeholderText: 'Host')
            @subview 'srcPathEditor', new EditorView(mini:true, placeholderText: 'Source')
            @subview 'targetPathEditor', new EditorView(mini:true, placeholderText: 'Destination')
            @div class: 'block pull-right', =>
              @button outlet: 'cancelButton', class: 'inline-block btn', "Cancel"
              @button outlet: 'rsyncButton', class: 'inline-block btn btn-primary', "Rsync It"
          @div outlet: 'progressIndicator', class: 'block', =>
            @progress outlet: 'progressBar', class: 'inline-block', max: '100', value: '0'
            @span outlet: 'throughPutMeter', class: 'inline-block'
            @span class: 'inline-block'
            @div outlet: 'changesBox', =>
              @subview 'changeList', new ChangeListView()

  initialize: (serializeState) ->
    @handleEvents()
    atom.workspaceView.command "atom-rsync:current-file", => @rsyncCurrentFile()
    # atom.workspaceView.command "atom-rsync:open-files", => @rsyncOpenFiles()
    # atom.workspaceView.command "atom-rsync:current-folder", => @rsyncCurrentFolder()
    @rsync = null

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
    # Returns an object that can be retrieved when package is activated

  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  handleEvents: ->
    @rsyncButton.on 'click', => @rsyncIt()
    @localButton.on 'click', => @makeLocal()
    @remoteButton.on 'click', => @makeRemote()
    @cancelButton.on 'click', => @destroy()

  projectRelativePath: (fullPath) ->
    path.relative atom.project.getPath(), fullPath

  rsyncCurrentFile: ->
    @rsync = new Rsync()
    currentFilePath = srcPath = atom.workspace.getActiveEditor().getPath()

    @title.text "RSync Current File"
    @displaySelf()

    @srcPathEditor.setText @projectRelativePath currentFilePath
    @srcPathEditor.attr "disabled", "disabled"

  rsyncOpenFiles: ->
    @rsync = new Rsync()

    for editor in atom.workspace.getEditors()
      editor.getTitle()

    @title.text "Rsync Open Files"
    @displaySelf()

  displaySelf: ->
    @showRsyncForm()
    atom.workspaceView.append(this)

    @targetPathEditor.focus()

  rsyncIt: ->
    @showProgressIndicator()

    @rsync.targetPath @targetPathEditor.getText()
    @rsync.srcPath @srcPathEditor.getText()
    @rsync.host = @hostEditor.getText()

    @rsync.send(
      (error, code, cmd) ->
        console.log error
        console.log code
        console.log cmd
      (data) =>
        progress = Rsync.progress(data)
        throughPut = Rsync.throughPut(data)

        if progress? then @progressBar.attr 'value', progress
        if throughPut? then @throughPutMeter.text(throughPut)
      (data) ->
        console.log data
    )

  makeRemote: ->
    @remoteButton.addClass('selected')
    @localButton.removeClass('selected')
    @hostEditor.show()
    @rsync.isRemote = true

  makeLocal: ->
    @localButton.addClass('selected')
    @remoteButton.removeClass('selected')
    @hostEditor.hide()
    @rsync.isRemote = false

  showRsyncForm: ->
    if @rsync.isRemote then @makeRemote() else @makeLocal()
    # @targetPathEditor.setText @rsync.targetPath()

    @toolbar.show()
    @rsyncForm.show()
    @urlDisplay.hide()
    @progressIndicator.hide()

  showProgressIndicator: ->
    @toolbar.hide()
    # @rsyncForm.hide()
    @urlDisplay.hide()
    @progressIndicator.show()
