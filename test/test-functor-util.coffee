should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
U = require(path.join(LIB_DIR,'functor-util')).FunctorUtil

is_odd               = (n)->((n%2) is 1)
is_even              = (n)->((n%2) is 0)
is_three             = (n)->(n is 3)
is_four              = (n)->(n is 4)
is_six               = (n)->(n is 6)
is_multiple_of_three = (n)->((n%3) is 0)

plus_one             = (n)->n+1
times_two            = (n)->n*2

describe 'FunctorUtil', ->
  describe 'and',->
    it "returns true when no predicates are specified",(done)->
      ((U.and())()).should.be.ok
      done()
    it "returns true when no predicates are specified (array case)",(done)->
      ((U.and([]))()).should.be.ok
      done()
    it "returns true if all given predicates are true (1 arg case)",(done)->
      q = U.and(is_odd)
      q(3).should.be.ok
      q(4).should.not.be.ok
      done()
    it "returns true if all given predicates are true (2 arg case)",(done)->
      q = U.and(is_odd,is_multiple_of_three)
      q(3).should.be.ok
      q(4).should.not.be.ok
      q(5).should.not.be.ok
      q(6).should.not.be.ok
      q(9).should.be.ok
      done()
    it "returns true if all given predicates are true (3 arg case)",(done)->
      q = U.and(is_odd,is_three,is_multiple_of_three)
      q(3).should.be.ok
      q(4).should.not.be.ok
      q(5).should.not.be.ok
      q(6).should.not.be.ok
      q(9).should.not.be.ok
      done()
    it "returns true if all given predicates are true (array case)",(done)->
      q = U.and([is_odd,is_three,is_multiple_of_three])
      q(3).should.be.ok
      q(4).should.not.be.ok
      q(5).should.not.be.ok
      q(6).should.not.be.ok
      q(9).should.not.be.ok
      done()

  describe 'or',->
    it "returns false when no predicates are specified",(done)->
      ((U.or())()).should.not.be.ok
      done()
    it "returns false when no predicates are specified (array case)",(done)->
      ((U.or([]))()).should.not.be.ok
      done()
    it "returns true if any given predicate are true (1 arg case)",(done)->
      q = U.or(is_odd)
      q(3).should.be.ok
      q(4).should.not.be.ok
      done()
    it "returns true if any given predicates are true (2 arg case)",(done)->
      q = U.or(is_odd,is_four)
      q(3).should.be.ok
      q(4).should.be.ok
      q(5).should.be.ok
      q(6).should.not.be.ok
      done()
    it "returns true if all given predicates are true (3 arg case)",(done)->
      q = U.or(is_odd,is_four,is_six)
      q(3).should.be.ok
      q(4).should.be.ok
      q(5).should.be.ok
      q(6).should.be.ok
      q(9).should.be.ok
      done()
    it "returns true if all given predicates are true (array case)",(done)->
      q = U.or([is_odd,is_four,is_six])
      q(3).should.be.ok
      q(4).should.be.ok
      q(5).should.be.ok
      q(6).should.be.ok
      q(9).should.be.ok
      done()

  describe 'xor',->
    it "returns false when no predicates are specified",(done)->
      ((U.xor())()).should.not.be.ok
      done()
    it "returns false when no predicates are specified (array case)",(done)->
      ((U.xor([]))()).should.not.be.ok
      done()
    it "returns true if exactly one given predicate is true (1 arg case)",(done)->
      q = U.xor(is_odd)
      q(3).should.be.ok
      q(4).should.not.be.ok
      done()
    it "returns true if exactly one given predicate is true (2 arg case)",(done)->
      q = U.xor(is_odd,is_three)
      q(1).should.be.ok
      q(2).should.not.be.ok
      q(3).should.not.be.ok
      q(4).should.not.be.ok
      q(5).should.be.ok
      done()
    it "returns true if exactly one given predicates is true (3 arg case)",(done)->
      q = U.xor(is_odd,is_three,is_four)
      q(1).should.be.ok
      q(2).should.not.be.ok
      q(3).should.not.be.ok
      q(4).should.be.ok
      q(5).should.be.ok
      done()
    it "returns true if exactly one given predicates is true (array)",(done)->
      q = U.xor([is_odd,is_three,is_four])
      q(1).should.be.ok
      q(2).should.not.be.ok
      q(3).should.not.be.ok
      q(4).should.be.ok
      q(5).should.be.ok
      done()

  describe 'not',->
    it "returns false when the given predicate returns true",(done)->
      q = U.not(U.true)
      U.true().should.be.ok
      q().should.not.be.ok
      done()
    it "returns true when the given predicate returns false",(done)->
      q = U.not(U.false)
      U.false().should.not.be.ok
      q().should.be.ok
      done()

  describe 'not',->
    it "returns false when the given predicate returns true",(done)->
      q = U.not(U.true)
      U.true().should.be.ok
      q().should.not.be.ok
      done()
    it "returns true when the given predicate returns false",(done)->
      q = U.not(U.false)
      U.false().should.not.be.ok
      q().should.be.ok
      done()

  describe 'compose',->
    it "returns f() given f()",(done)->
      h = U.compose(plus_one)
      h(0).should.equal(1)
      h(1).should.equal(2)
      done()

    it "returns f(g()) given f(), g()",(done)->
      h = U.compose(times_two,plus_one)
      h(0).should.equal(2) # 2*(0+1)
      h(1).should.equal(4) # 2*(1+1)
      done()

    it "returns f(g(h())) given f(), g(), h()",(done)->
      h = U.compose(plus_one,times_two,plus_one)
      h(0).should.equal(3) # 1+(2*(0+1))
      h(1).should.equal(5) # 1+(2*(1+1))
      done()

    it "returns f(g(h(i()))) given f(), g(), h(), i()",(done)->
      h = U.compose(times_two,plus_one,times_two,plus_one)
      h(0).should.equal(6)
      h(1).should.equal(10)
      done()

    it "returns f(g(h(i()))) given f(), g(), h(), i() (array case)",(done)->
      h = U.compose([times_two,plus_one,times_two,plus_one])
      h(0).should.equal(6)
      h(1).should.equal(10)
      done()

    it "even works with very long chains (100)",(done)->
      list = []
      for i in [0...100]
        list.push plus_one
      f = U.compose(list)
      f(0).should.equal(100)
      f(1).should.equal(101)
      done()

    it "even works with very long chains (1000)",(done)->
      list = []
      for i in [0...1000]
        list.push plus_one
      f = U.compose(list)
      f(0).should.equal(1000)
      f(1).should.equal(1001)
      done()

  describe 'for',->
    it "acts like a loop",(done)->
      index = sum = null
      is_done = false

      init = ()-> index = sum = 0
      cond = ()-> return index < 10
      action = ()-> sum += index
      step = ()-> index += 1
      when_done = ()-> is_done = true

      U.for(init,cond,action,step,when_done)

      sum.should.equal(0+1+2+3+4+5+6+7+8+9)
      when_done.should.be.ok
      done()

    it "only condition is required",(done)->
      count = 3
      cond = ()->return (--count) > 0
      U.for(null,cond)
      count.should.equal 0
      done()


  describe 'for_async',->
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
      U.for_async(fn_init,fn_cond,fn_act,fn_incr,fn_whendone)

  describe 'for_each',->
    it "acts like Array.forEach",(done)->
      sum = 0
      is_done = false
      action = (value)-> sum += value
      when_done = ()-> is_done = true
      U.for_each([0...10],action,when_done)
      sum.should.equal(0+1+2+3+4+5+6+7+8+9)
      when_done.should.be.ok
      done()

  describe 'for_each_async',->
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
      U.for_each_async [0,1,2,3,4,5,6,7,8,9], action, whendone


  describe 'add_callback',->
    it 'invokes a callback method at the end of another method',(done)->
      result = null
      sum = (args...)->
        result = 0
        for v in args
          result += v
        return result
      sum( 1, 2, 3, 4, 5 ).should.equal 15
      sum_with_callback = U.add_callback(sum)
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
      U.for_each_async [0,1,2,3,4,5,6,7,8,9], U.add_callback(sync_action), whendone


  describe 'fork',->
    it 'does\'t invoke callback until all results are obtained',(done)->
      methods = []
      expected = []
      for i in [0...10]
        do (i)->
          methods.push (callback)->callback("Method #{i}")
          expected[i] = "Method #{i}"
      callback = (results)=>
        for result in results
          (result[0] in expected).should.be.ok
        done()
      U.fork(methods,callback)

    it 'allows a variable number of arguments returned by callback',(done)->
      methods = [ ((cb)->cb(1)), ((cb)->cb(2,2)), ((cb)->cb(3,3,3)), ((cb)->cb(4,4,4,4)) ]
      callback = (results)=>
        for result,i in results
          result.length.should.equal i+1
          for value in result
            value.should.equal i+1
        done()
      U.fork(methods,callback)

    it 'works with truly asynchronous methods',(done)->
      FILE_1 = path.join(__dirname,'test-functor-util.coffee')
      FILE_2 = path.join(__dirname,'does-not-exist')
      FILE_3 = path.join(__dirname,'data_file.txt')
      methods = []
      methods.push (cb)-> fs.exists(FILE_1,cb)
      methods.push (cb)-> fs.exists(FILE_2,cb)
      methods.push (cb)-> fs.exists(FILE_3,cb)
      callback = (results)->
        results[0][0].should.be.ok
        results[1][0].should.not.be.ok
        results[2][0].should.be.ok
        done()
      U.fork(methods,callback)

    it 'passes the specified args to the methods',(done)->
      method_args = []
      method_args.push [ path.join(__dirname,'test-functor-util.coffee') ]
      method_args.push [ path.join(__dirname,'does-not-exist') ]
      method_args.push [ path.join(__dirname,'data_file.txt') ]

      methods = []
      methods.push (file,cb)-> fs.exists(file,cb)
      methods.push (file,cb)-> fs.exists(file,cb)
      methods.push (file,cb)-> fs.exists(file,cb)

      callback = (results)->
        results[0][0].should.be.ok
        results[1][0].should.not.be.ok
        results[2][0].should.be.ok
        done()

      U.fork(methods,method_args,callback)


  describe 'throttled fork',->
    it 'does\'t invoke callback until all results are obtained',(done)->
      methods = []
      expected = []
      for i in [0...10]
        do (i)->
          methods.push (callback)->callback("Method #{i}")
          expected[i] = "Method #{i}"
      callback = (results)=>
        for result in results
          (result[0] in expected).should.be.ok
        done()
      U.throttled_fork(2,methods,callback)

    it 'passes the specified args to the methods',(done)->
      method_args = []
      method_args.push [ path.join(__dirname,'test-functor-util.coffee') ]
      method_args.push [ path.join(__dirname,'does-not-exist') ]
      method_args.push [ path.join(__dirname,'data_file.txt') ]

      methods = []
      methods.push (file,cb)-> fs.exists(file,cb)
      methods.push (file,cb)-> fs.exists(file,cb)
      methods.push (file,cb)-> fs.exists(file,cb)

      callback = (results)->
        results[0][0].should.be.ok
        results[1][0].should.not.be.ok
        results[2][0].should.be.ok
        done()

      U.throttled_fork(2,methods,method_args,callback)
