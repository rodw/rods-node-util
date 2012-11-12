# `Stopwatch`
#
# A simple timer.
#
# ## Basic Use
#
# timer = Stopwtach.start();
# // ...do something...
# timer.stop();
# console.log("Start Time:",timer.start_time);
# console.log("Finish Time::",timer.finish_time);
# console.log("Elapsed Time:",timer.elapsed_time);
#
# ## Wrapped (Synchronous)
# 
# timer = Stopwatch.time_sync( some_method );
# console.log("some_method took",timer.elapsed_time,"millis to complete.);
#
# ## Wrapped (Asynchronous)
# 
# Stopwatch.time_async( some_method, function(timer) {
#   console.log("some_method took",timer.elapsed_time,"millis to complete.);
# });

IS_NODE = (typeof require != 'undefined' && typeof module != 'undefined')

class Stopwatch
  start:(base={})->
    data = {}
    if base?
      for n,v of base
        if base.hasOwnProperty n
          data[n] = v
    data.start_time = new Date()
    data.stop = ()->
      data.finish_time = new Date()
      data.elapsed_time = data.finish_time - data.start_time
      delete data.stop
      return data
    return data

  time_sync:(base,fn)->
    if typeof base == 'function'
      fn = base
      base = fn
    timer = @start(base)
    fn()
    return timer.stop()

  time_async:(base={},fn,callback,use_next_tick = true)=>
    if typeof base == 'function'
      callback = fn
      fn = base
      base = {}
    runner = ()=> 
      result = null
      try
        result = @time_sync(base,fn)
      finally
        if callback?
          callback result
    if use_next_tick
      process.nextTick(runner)
    else
      setTimeout(runner,0)

export_methods_to = (obj)->
  stopwatch = new Stopwatch()
  obj.start = stopwatch.start
  obj.time_sync = stopwatch.time_sync
  obj.time_async = stopwatch.time_async
  return obj
  
exports = exports ? this
exports = export_methods_to(exports)
exports.export_methods_to = export_methods_to
