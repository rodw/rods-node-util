# # A Test Suite for rods-node-util
 
# `rods-node-util` is a library of small JavaScript
# (CoffeeScript) functions primarily intended for use
# within a Node.js enviornment.

# These tests are written using the
# [mocha](http://visionmedia.github.com/mocha/) test
# scaffolding.

# The tests are written using the
# [should.js](https://github.com/visionmedia/should.js)
# assertion framework.
should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Util = require(path.join(LIB_DIR,'rods-node-util'))

# ## Tests

describe 'Rod\'s Node.js Utilities', ->
  describe 'trim',->
    it 'shouldn\'t choke on null values',(done)->
      result = Util.trim(null)
      (result?).should.not.be.ok
      done()
      
    it 'should return blank for blank',(done)->
      result = Util.trim('')
      result.should.equal ''
      done()
      
    it 'should trim leading and trailing whitespace',(done)->
      Util.trim(' xyzzy').should.equal('xyzzy')
      Util.trim('  xyzzy').should.equal('xyzzy')
      Util.trim('xyzzy ').should.equal('xyzzy')
      Util.trim('xyzzy ').should.equal('xyzzy')
      Util.trim(' xyzzy ').should.equal('xyzzy')
      Util.trim("\txyzzy").should.equal('xyzzy')
      Util.trim("\t \txyzzy\t ").should.equal('xyzzy')
      done()
      
    it 'should trim vertical whitespace',(done)->
      Util.trim("\nxyzzy\n\n").should.equal('xyzzy')
      Util.trim("\rxyzzy\r\r").should.equal('xyzzy')
      Util.trim("\fxyzzy\f\f").should.equal('xyzzy')
      Util.trim("\r\fxyzzy\r\f\r\f").should.equal('xyzzy')
      Util.trim(" \n \t \r\f xyzzy \n\t ").should.equal('xyzzy')
      done()
      
  describe 'object_to_array',->
    it 'doesn\'t choke on null values',(done)->
      result = Util.object_to_array(null)
      (result?).should.not.be.ok
      done()
      
    it 'return attributes but not standard methods',(done)->
      obj = new Date()
      result = Util.object_to_array(obj)
      result.length.should.equal 0
      obj.foo = "bar"
      result = Util.object_to_array(obj)
      result.length.should.equal 1
      done()
      
    it 'returns an array of name/value pairs',(done)->
      obj = { alpha:1, beta:2, gamma:3 }
      result = Util.object_to_array(obj)
      result.length.should.equal 3
      found_a = found_b = found_c = found_other = false
      for e in result
        if e[0] is 'alpha' && e[1] is 1
          found_a = true
        else if e[0] is 'beta' && e[1] is 2
          found_b = true
        else if e[0] is 'gamma' && e[1] is 3
          found_c = true
        else
          found_other = true
      found_other.should.not.be.ok
      found_a.should.be.ok
      found_b.should.be.ok
      found_c.should.be.ok
      done()

    it 'returns includes newly declared functions ',(done)->
      obj = { alpha:1, beta:2, gamma:3 }
      obj.foo = ()->console.log("some function")
      result = Util.object_to_array(obj)
      result.length.should.equal 4
      found_a = found_b = found_c = found_foo = found_other = false
      for e in result
        if e[0] is 'alpha' && e[1] is 1
          found_a = true
        else if e[0] is 'beta' && e[1] is 2
          found_b = true
        else if e[0] is 'gamma' && e[1] is 3
          found_c = true
        else if e[0] is 'foo' && typeof e[1] is 'function'
          found_foo = true
        else
          found_other = true
      found_other.should.not.be.ok
      found_a.should.be.ok
      found_b.should.be.ok
      found_c.should.be.ok
      found_foo.should.be.ok
      done()
      
  describe 'sort_by_value',->
    it 'doesn\'t choke on null values',(done)->
      result = Util.sort_by_value(null)
      (result?).should.not.be.ok
      done()

    it 'returns an array of pairs, sorted by value',(done)->
      map = { a:5, e:1, f:0, c:3, b:4, d:2}
      result = Util.sort_by_value(map)
      result.length.should.equal(6)
      for pair,index in result
        pair[1].should.equal index
        if index == 5
          pair[0].should.equal 'a'
        else if index == 4
          pair[0].should.equal 'b'
        else if index == 3
          pair[0].should.equal 'c'
        else if index == 2
          pair[0].should.equal 'd'
        else if index == 1
          pair[0].should.equal 'e'
        else if index == 0
          pair[0].should.equal 'f'
      done()

      
  describe 'sort_by_key',->
    it 'doesn\'t choke on null values',(done)->
      result = Util.sort_by_value(null)
      (result?).should.not.be.ok
      done()

    it 'returns an array of pairs, sorted by key',(done)->
      map = { a:5, e:1, f:0, c:3, b:4, d:2}
      result = Util.sort_by_key(map)
      result.length.should.equal(6)
      for pair,index in result
        pair[1].should.equal index
        if index == 5
          pair[0].should.equal 'a'
        else if index == 4
          pair[0].should.equal 'b'
        else if index == 3
          pair[0].should.equal 'c'
        else if index == 2
          pair[0].should.equal 'd'
        else if index == 1
          pair[0].should.equal 'e'
        else if index == 0
          pair[0].should.equal 'f'
      done()
