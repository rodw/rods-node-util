should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
U = require(path.join(LIB_DIR,'file-util')).FileUtil
DATA_FILE = path.join(__dirname,'data_file.txt')
DATA =
"""
line 1
  line 2
# line 3 is a comment
line 4

 # line 6 is a comment
line 7

"""

describe "FileUtil",->
  describe 'file_to_string',->
    it "reads a file into a string",(done)->
      U.file_to_string DATA_FILE, (err,data)->
        data.should.equal(DATA)
        done()

  describe 'file_to_string_sync',->
    it "reads a file into a string",(done)->
      data = U.file_to_string_sync(DATA_FILE)
      data.should.equal(DATA)
      done()

  describe 'file_to_array_sync',->
    it "makes robust configuration or data files easy",(done)->
      result = U.file_to_array_sync(DATA_FILE)
      expected = [ 'line 1',
                   'line 2',
                   'line 4',
                   'line 7'  ]
      for line in expected
        (result.shift()).should.equal line
      result.length.should.equal 0
      done()
