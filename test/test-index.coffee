should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
U = require(path.join(LIB_DIR,'index'))

describe 'Index', ->

  it 'has Stopwatch methods',->
    (U.Stopwatch?.start?).should.be.ok

  it 'has FunctorUtil methods',->
    (U.FunctorUtil?.true?).should.be.ok

  it 'has StringUtil methods',->
    (U.StringUtil?.trim?).should.be.ok

  it 'has FileUtil methods',->
    (U.FileUtil?.file_to_string?).should.be.ok

  it 'has ContainerUtil methods',->
    (U.ContainerUtil?.clone?).should.be.ok
