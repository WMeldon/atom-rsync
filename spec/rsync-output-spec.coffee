RsyncOutput = require '../lib/rsync-output'

describe "AtomRsyncOutput Parser", ->
  rsyncOutput = null
  rsyncOutputDone = null

  beforeEach ->
    data = """
        *deleting  |file74
        <f++++++++++|file86
        227,542,089  99%    9.84MB/s    0:00:22 (xfr#68, to-chk=15/84)
        <f++++++++++|file87
        227,542,089  99%    9.84MB/s    0:00:22 (xfr#69, to-chk=14/84)
        <f++++++++++|file88
        227,542,089  99%    9.84MB/s    0:00:22 (xfr#70, to-chk=13/84)
        <f++++++++++|file89
        227,542,089  99%    9.84MB/s    0:00:22 (xfr#71, to-chk=12/84)
        <f++++++++++|file9
        227,542,094  99%    9.84MB/s    0:00:22 (xfr#72, to-chk=11/84)
    """
    noMatchData = """
        sent 524352200 bytes  received 118 bytes  11276393.94 bytes/sec
        total size is 524294258  speedup is 1.00
    """

    rsyncOutput = new RsyncOutput(data)
    rsyncOutputDone = new RsyncOutput(noMatchData)

  it "should parse progress correctly", ->
    returnsValue = rsyncOutput.progress()
    returnsNothing = rsyncOutputDone.progress()

    expect(returnsValue).toEqual '99'
    expect(returnsNothing).toBeUndefined()

  it "should parse through put correctly", ->
    returnsValue = rsyncOutput.throughPut()
    returnsNothing = rsyncOutputDone.throughPut()

    expect(returnsValue).toEqual '9.84MB/s'
    expect(returnsNothing).toBeUndefined()

  it "should parse log output correctly", ->
    captures = rsyncOutput.itemizedChanges()
    capturesNothing = rsyncOutputDone.itemizedChanges()

    deleting = captures[0]
    creating = captures[1]

    expect(deleting).toContain('*')
    expect(deleting).toContain('deleting')
    expect(deleting).toContain('file74')
    expect(creating).toContain('<')
    expect(creating).toContain('f')
    expect(creating).toContain('file86')
    expect(capturesNothing).toEqual([])

  describe "Rsync Itemized Change Parser", ->
    deletingStatus = null
    creatingStatus = null
    beforeEach ->
      deletingStatus = rsyncOutput.statuses()[0]
    it "should instantiate deleted status objects correctly", ->
      status = deletingStatus

      expect(status.action).toEqual('*')
      expect(status.fileType).toEqual('deleting')
      expect(status.mods).toEqual('  ')
      expect(status.fileName).toEqual('file74')
      
