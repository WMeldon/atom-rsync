module.exports =

class RsyncOutputParser
  constructor: (data) ->
    @data = data.toString()
    @_statuses = []

  progress: ->
    @data.match(/([0-9]*)(?:%)/)?[1]

  throughPut: ->
    @data.match(/(\d*\.?\d+)(?:MB\/s)/)?[0]

  # See http://rsync.samba.org/ftp/rsync/rsync.html [--itemize-changes]
  itemizedChanges: ->
    exp = ///
     ([.<>ch*]) #update being done [0]
     (deleting|[fdlDS]) #file-type OR deleting [1]
     (.*) #attribute modifications [2]
     \| #until pipe-seperator
     (.*) #capture file name [3]
    ///g

    # Exec must be used if capture groups are needed with /g
    # We only want elements 1..4 of the matches
    matches =  while match = exp.exec @data
      match[1..4]

  _addStatus: (change) ->
    [action, fileType, mods, fileName] = change

    @_statuses.push new RsyncItemizedChange(action, fileType, mods, fileName)


  statuses: ->
    @_addStatus change for change in @itemizedChanges()
    @_statuses



class RsyncItemizedChange
  constructor: (@action, @fileType, @mods, @fileName) ->
