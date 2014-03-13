RsyncModel = require '../lib/rsync-model'
{WorkspaceView} = require 'atom'

describe "AtomRsync Model", ->
  rsyncModel = null

  beforeEach ->
    rsyncModel = new RsyncModel()

  it "should get srcPaths correctly", ->
    rsyncModel.sources ['foo', 'bar', 'baz']
    srcPath = rsyncModel.srcPath()
    expect(srcPath).toEqual('foo, bar, baz')

  it "should set srcPaths correctly", ->
    rsyncModel.sources null
    rsyncModel.srcPath('foo, bar, baz')

    srcPath = rsyncModel.srcPath()
    sources = rsyncModel.sources()

    expect(srcPath).toEqual('foo, bar, baz')
    expect(sources).toEqual ['foo', 'bar', 'baz']

  it "should set sources correctly", ->
    rsyncModel._sources = ['foo', 'bar', 'baz']
    sources = rsyncModel.sources()
    expect(sources).toEqual ['foo', 'bar', 'baz']

  it "should get sources correctly", ->
    rsyncModel.sources ['foo', 'bar', 'baz']
    sources = rsyncModel._sources
    expect(sources).toEqual ['foo', 'bar', 'baz']

  it "should get local targets correctly", ->
    rsyncModel.targetPath '/foo/bar/baz '
    rsyncModel.isRemote = false
    target = rsyncModel.targetPath()
    expect(target).toEqual '/foo/bar/baz'

  it "should get remote targets correctly", ->
    rsyncModel.targetPath '/foo/bar/baz'
    rsyncModel.host = 'user@host'
    rsyncModel.isRemote = true
    target = rsyncModel.targetPath()
    expect(target).toEqual 'user@host:/foo/bar/baz'
