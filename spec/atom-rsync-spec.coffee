AtomRsync = require '../lib/atom-rsync'
{WorkspaceView} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

xdescribe "AtomRsync", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    activationPromise = atom.packages.activatePackage('atomRsync')

  describe "when the atom-rsync:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-rsync')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'atom-rsync:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-rsync')).toExist()
        atom.workspaceView.trigger 'atom-rsync:toggle'
        expect(atom.workspaceView.find('.atom-rsync')).not.toExist()
