should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RodsNodeUtil = require(path.join(LIB_DIR,'index'))

describe 'Index', ->
  it 'has Util methods',->
    (RodsNodeUtil.file_to_array?).should.be.ok
  it 'has Stopwatch methods',->
    (RodsNodeUtil.Stopwatch?.start?).should.be.ok
