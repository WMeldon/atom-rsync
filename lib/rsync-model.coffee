RsyncWrapper = require 'rsync'

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
module.exports =

class Rsync
  constructor: ->
    @isRemote = atom.config.get('atom-rsync.uploadToRemote')
    @rsyncWrapper = new RsyncWrapper()
    @_sources = []
    @_destination = ''
    @host = ''

  srcPath: (value) ->
    if !arguments.length
      @_sources.join ', '
    else
      @_sources = (path.trim() for path in value.split ',')

  targetPath: (value) ->
    if !arguments.length
      if @isRemote then @remotePath() else @_destination.trim()
    else
      @_destination = value.trim()

  remotePath: ->
    "#{@host}:#{@_destination.trim()}"

  sources: (value) ->
    if !arguments.length
      @_sources
    else
      @_sources = value

  send: (callback, output, error) ->
    @rsyncWrapper.executable atom.config.get('atom-rsync.rsyncPath')
      .progress()
      .flags 'avv'
      .format '%i|%n'
      .information 'progress2'
      .source(@srcPath())
      .destination(@targetPath())
      .debug(true)
      .cwd(atom.project.getPath())

    @rsyncWrapper.execute(callback, output, error)
