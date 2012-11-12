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
  describe 'file_to_array',->
    DATA_FILE = path.join(__dirname,'data_file.txt')
    
    it 'should read a file into an array of lines',(done)->      
      result = Util.file_to_array(DATA_FILE,{})
      expected = [
        'line 1',
        '  line 2   ',
        '# line 3 is a comment',
        'line 4',
        '',
        ' # line 6 is a comment',
        'line 7  ',
        ''
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()
          
    it 'should trim, skip blanks and skip # comments by default',(done)->      
      result = Util.file_to_array(DATA_FILE)
      expected = [
        'line 1',
        'line 2',
        'line 4',
        'line 7'
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()
      
    it 'should trim when asked',(done)->      
      result = Util.file_to_array(DATA_FILE,{trim:true})
      expected = [
        'line 1',
        'line 2',
        '# line 3 is a comment',
        'line 4',
        '',
        '# line 6 is a comment',
        'line 7',
        ''
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()
            
    it 'should trim and skip comments when asked',(done)->      
      result = Util.file_to_array(DATA_FILE,{trim:true,comment_char:'#'})
      expected = [
        'line 1',
        'line 2',
        'line 4',
        '',
        'line 7',
        ''
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()
          
    it 'should allow custom comment chars',(done)->      
      result = Util.file_to_array(DATA_FILE,{comment_char:'l'})
      expected = [
        '# line 3 is a comment',
        '',
        ' # line 6 is a comment',
        ''
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()

    it 'should strip blanks when asked',(done)->      
      result = Util.file_to_array(DATA_FILE,{strip_blanks:true})
      expected = [
        'line 1',
        '  line 2   ',
        '# line 3 is a comment',
        'line 4',
        ' # line 6 is a comment',
        'line 7  '
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()
            
    it 'should trim and strip blanks when asked',(done)->      
      result = Util.file_to_array(DATA_FILE,{strip_blanks:true,trim:true})
      expected = [
        'line 1',
        'line 2',
        '# line 3 is a comment',
        'line 4',
        '# line 6 is a comment',
        'line 7'
      ]
      for line in expected
        line.should.equal result.shift()
      result.length.should.equal 0
      done()

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
      
      
  describe 'object_values',->
    it 'returns an array of object values',(done)->
      obj = { alpha:1, beta:2, gamma:3, another:3 }
      obj.foo = ()->console.log("some function")    
      result = Util.object_values(obj)
      result.length.should.equal 5
      (1 in result).should.be.ok
      (2 in result).should.be.ok
      (3 in result).should.be.ok
      found_function = false
      three_count = 0
      for v in result
        if v is 3
          three_count += 1
        else if typeof v is 'function'
          found_function = true
      found_function.should.be.ok
      three_count.should.equal 2
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

  describe 'comparator',->
    it 'returns a positive value if a > b',(done)->
      (Util.comparator(2,1) > 0).should.be.ok
      (Util.comparator(1,2) < 0).should.be.ok
      (Util.comparator(2,2) == 0).should.be.ok
      (Util.comparator('z','a') > 0).should.be.ok
      (Util.comparator('a','z') < 0).should.be.ok
      (Util.comparator('z','z') == 0).should.be.ok
      done()      
            
  describe 'sort_by_value',->
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
    it 'returns an array of pairs, sorted by key',(done)->
      map = { a:0, e:4, f:5, c:2, b:1, d:3}
      result = Util.sort_by_key(map)
      result.length.should.equal(6)
      for pair,index in result
        pair[1].should.equal index
        if index == 0
          pair[0].should.equal 'a'
        else if index == 1
          pair[0].should.equal 'b'
        else if index == 2
          pair[0].should.equal 'c'
        else if index == 3
          pair[0].should.equal 'd'
        else if index == 4
          pair[0].should.equal 'e'
        else if index == 5
          pair[0].should.equal 'f'
      done()
      
  describe 'transpose function',->
    it 'helps sort by value, descending',(done)->
      map = { a:5, e:1, f:0, c:3, b:4, d:2}
      result = Util.sort_by_value(map,Util.transpose(Util.comparator))
      result.length.should.equal(6)
      for pair,index in result
        pair[1].should.equal (5-index)
      done()            

  describe 'frequency_count',->
    it 'returns a map of unique array elements to number of occurrences in array',(done)->
      a = [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 'watermelon', 'banana', 'watermelon' ]
      f = Util.frequency_count(a)
      (f[0]?).should.not.be.ok
      f[1].should.equal 1
      f[2].should.equal 2
      f[3].should.equal 3
      f[4].should.equal 4
      f['watermelon'].should.equal 2
      f['banana'].should.equal 1
      (f['apple']?).should.not.be.ok
      done()

  describe 'async_for_loop',->
    it 'supports a simple counter',(done)->
      expected = [0,1,2,3,4,5,6,7,8,9]    
      i = 0
      actual = []
      fn_init = ()-> i = 0 
      fn_cond = ()-> i < 10
      fn_act = (next)->
        actual.push(i)
        next()
      fn_incr = ()-> i = i + 1
      fn_whendone = ()->
        for v,i in expected
          v.should.equal(actual[i])
        done()
      Util.async_for_loop(fn_init,fn_cond,fn_act,fn_incr,fn_whendone)

  describe 'async_for_each',->
    it 'can iterate over the elements of a list',(done)->
      expected = [0,1,2,3,4,5,6,7,8,9]
      actual = []
      action = (value, index, array, next)->
        actual.push value
        next()
      whendone = ()->
        for v,i in expected
          v.should.equal(actual[i])
        done()
      Util.async_for_each [0,1,2,3,4,5,6,7,8,9], action, whendone 

  describe 'add_callback',->
    it 'invokes a callback method at the end of another method',(done)->
      result = null
      sum = (args...)->
        result = 0
        for v in args
          result += v
        return result
      sum( 1, 2, 3, 4, 5 ).should.equal 15
      sum_with_callback = Util.add_callback(sum)
      sum_with_callback 1, 2, 3, 4, 5, (result)->
        result.should.equal 15
        done()
        
    it 'can help us use a synchronous method when an asynchronous-one is expected',(done)->
      expected = [0,1,2,3,4,5,6,7,8,9]
      actual = []
      sync_action = (value, index, array)->actual.push value
      whendone = ()->
        for v,i in expected
          v.should.equal(actual[i])
        done()
      Util.async_for_each [0,1,2,3,4,5,6,7,8,9], Util.add_callback(sync_action), whendone 
