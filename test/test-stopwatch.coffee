should    = require 'should'
fs        = require 'fs'
path      = require 'path'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HOMEDIR   = path.join __dirname, '..' 
LIB_COV   = path.join HOMEDIR, 'lib-cov' 
LIB       = path.join HOMEDIR, 'lib'
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else LIB
Stopwatch = require(path.join(LIB_DIR,'stopwatch'))
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

describe "Stopwatch",->

  beforeEach (done)->
    @method_started = false
    
    @method_finished = false
    
    @a_slow_method = ()=>
      @method_started = true
      foo = [1]
      for i in [1...1000]
        sum = 0
        for j in [0...i]
          sum += foo[j]
        foo[i] = j
      @method_finished = true
    done()

  it "can be used for timing 'inline'.", (done)->
    timer = Stopwatch.start()
    timer.should.exist
    timer.start_time.should.exist
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    @a_slow_method()
    timer.stop()
    timer.start_time.should.exist
    timer.finish_time.should.exist
    timer.elapsed_time.should.exist
    timer.finish_time.should.be.above timer.start_time
    timer.elapsed_time.should.be.above 0
    should.not.exist timer.stop
    @method_started.should.be.ok
    @method_finished.should.be.ok
    done()

  it "doesn't always give the same time.", (done)->
    result = []
    result[2] = Stopwatch.start()
    result[1] = Stopwatch.start()
    result[0] = Stopwatch.start().stop()
    @a_slow_method()
    result[1] = result[1].stop()
    @a_slow_method()
    result[2] = result[2].stop()
    result[2].elapsed_time.should.be.above result[1].elapsed_time
    result[1].elapsed_time.should.be.above result[0].elapsed_time
    done()

  it "can be used for synchronous timing.", (done)->
    @method_started.should.not.be.ok
    @method_finished.should.not.be.ok
    result = Stopwatch.time_sync @a_slow_method
    @method_started.should.be.ok
    @method_finished.should.be.ok
    result.should.exist
    result.start_time.should.exist
    result.finish_time.should.exist
    result.elapsed_time.should.exist
    result.finish_time.should.be.above result.start_time
    result.elapsed_time.should.be.above 0
    done()

  it "can be used for asynchronous timing.", (done)->
    callback = (result)=>
      @method_started.should.be.ok
      @method_finished.should.be.ok
      result.should.exist
      result.start_time.should.exist
      result.finish_time.should.exist
      result.elapsed_time.should.exist
      result.finish_time.should.be.above result.start_time
      result.elapsed_time.should.be.above 0
      done()
    @method_started.should.not.be.ok
    @method_finished.should.not.be.ok
    Stopwatch.time_async @a_slow_method, callback
