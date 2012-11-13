fs = require 'fs'

add_util_methods = (Util)->

  # `file_to_array`
  #
  # (Synchronously) convert the contents of the given file
  # into to an array of lines.
  #
  # When options.strip_blanks is true (the default), blank lines
  # will be excluded from the output array.
  #
  # When options.trim is true (the default), leading and trailing
  # whitespace will be removed from each line.
  #
  # When options.comment_char is non-null (the default is `#`), lines
  # for which the comment_char is the first non-whitespae character
  # will be excluded from the output array.
  Util.file_to_array = (filename,options)->
    if !options?                                           # set default options if neeedd
      options = { strip_blanks: true, comment_char: '#', trim: true }
    a = fs.readFileSync(filename).toString()               # read file into a string
    a = a.split("\n")                                      # split by newlines
    if options.trim
      a = a.map (e)=>return Util.trim(e)                   # trim leading and trailing whilespace if needed
    predicate = null                                       # create a predicate for filtering if needed
    re = new RegExp("^[ \t]*"+options.comment_char)
    if options.strip_blanks && options.comment_char?       # strip blnak lines and commnetns
      predicate = (e)->(e.length > 0 && !re.test(e))
    else if !options.strip_blanks && options.comment_char? # strip comments only
      predicate = (e)->(!re.test(e))
    else if options.strip_blanks?                          # strip blank lines only
      predicate = (e)->(e.length > 0)
    a = a.filter(predicate) if predicate?                  # filter as needed
    return a                                               # and we're done

  # `trim` - remove leading and trailing whitespace
  Util.trim = (str)->
    if str?
      return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    else
      return str

  Util.clone = (map)->
    clone = {}
    for name,value of map
      clone[name] = value
    return clone
    
  Util.deep_clone = (map)->
    clone = {}
    for name,value of map
      if typeof value is 'array' || typeof value is 'object'
        clone[name] = Util.deep_clone(value)
      else
        clone[name] = value
    return clone

  # `object_to_array` - convert an object (map) into an array of name/value pairs
  Util.object_to_array = (object)->
    if object?
      a = []
      for k,v of object
        a.push [k,v]
      return a
    else
      return null

  # `map_to_array` - an alias for `object_to_array`.
  Util.map_to_array = Util.object_to_array

  # `object_values` - convert an object (map) into an array of values.
  # Also see `Object.keys`.
  Util.object_values = (object)->    
    a = []
    for k,v of object
      a.push v
    return a

  # `array_to_bag` - convert an array into a map
  # of elements to the number of times they occur
  # in the array.
  Util.array_to_bag = (a)->
    m = {}
    for e in a
      c = m[e] ? 0
      m[e] = c + 1
    return m

  # `frequency_count` - an alias for `array_to_bag`.
  Util.frequency_count = Util.array_to_bag

  # `comparator` - returns a negative value if a < b, a postive value if a > b or 0 otherwise
  Util.comparator = (a,b)->
    if a > b
      return 1
    else if a < b
      return -1
    else
      return 0

  # given f(a,b) returns g(a,b) = f(b,a)
  Util.transpose = (f)->
    return (a,b)->f(b,a)
        
  # `sort_by_value` - return an array of name/value pairs, ordred by value.
  Util.sort_by_value = (m,c = Util.comparator)-> (Util.map_to_array(m)).sort (a,b)-> c(a[1], b[1])

  # `sort_by_key` - return an array of name/value pairs, ordred by name.
  Util.sort_by_key =  (m,c = Util.comparator)-> (Util.map_to_array(m)).sort (a,b)-> c(a[0], b[0])

  # `async_for_loop` - Executes an asynchronous for loop.
  # 
  # Accepts 5 function-valued parameters:
  #  * `initialize` - an initialization function (no arguments passed, no return value is expected)
  #  * `condition` - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned)
  #  * `action` - the action to take (a single callback function is passed and should be invoked at the end of the action, no return value is expected)
  #  * `increment` - called at the end of every `action`, prior to `condition`  (no arguments passed, no return value is expected)
  #  * `whendone` - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected)
  #
  # For example, the loop:
  # 
  #    for(var i=0; i<10; i++) { console.log(i); }
  #
  # could be implemented as:
  #
  #     var i = 0;
  #     init = function() { i = 0; }
  #     cond = function() { return i < 10; }
  #     actn = function(next) { console.log(i); next(); }
  #     incr = function() { i = i + 1; }
  #     done = function() { }
  #     async_for_loop(init,cond,actn,incr,done)
  # 
  Util.async_for_loop = (initialize,condition,action,increment,whendone)->
    looper = ()->
      if condition()            
        action ()->
          increment()
          looper()
      else
        whendone() if whendone?
    initialize()            
    looper()

  # `async_for_each` - Executes an asynchronous forEach loop.
  # 
  # Accepts 3 parameters:
  #  * `list` - the array to iterate over
  #  * `action` - the function with the signature (value,index,list,next) indicating the action to take; the provided function `next` *must* be called at the end of processing
  #  * `whendone` - called at the end of the loop
  #
  # For example, the loop:
  # 
  #      [0..10].foreach (elt,index,array)-> console.log elt
  #
  # could be implemented as:
  # 
  #     async_for_each [0..10], (elt,index,array,next)->
  #       console.log elt
  #       next()
  # 
  Util.async_for_each = (list,action,whendone)->
    i = m = null
    init = ()-> i = 0; m = list.length
    cond = ()-> (i < m)
    incr = ()-> i += 1
    act  = (next)-> action(list[i],i,list,next)
    Util.async_for_loop init, cond, act, incr, whendone

  # For a given synchronous function `f(a,b,c,...)`
  # returns a new function `g(a,b,c,...,callback)`
  # that is equivalent to
  # 
  #     callback(f(a,b,c,...));
  # 
  # The resulting method isn't asynchronous, but
  # approximates the method signature and control flow
  # used by asynchronous methods. This makes it easy
  # to use a synchronous method where an
  # asynchronous one is expected.
  Util.add_callback = (f)->
    return (args...)=>
      callback = args.pop()
      callback(f(args...))

  Util.fork = (methods, args_for_methods, callback)->
    if !callback? && typeof args_for_methods is 'function'
      callback = args_for_methods
      args_for_methods = null
    results = []
    remaining_callbacks = methods.length
    for method, index in methods
      do (method,index)->
        method_args = args_for_methods?[index] ? []
        method method_args..., (callback_args...)->
          results[index] = callback_args
          remaining_callbacks--
          if remaining_callbacks is 0
            callback(results)

  Util.throttled_fork = (max_parallel, methods, args_for_methods, callback)->
    if !callback? && typeof args_for_methods is 'function'
      callback = args_for_methods
      args_for_methods = null
    results = []
    currently_running = 0
    next_to_run = 0
    remaining_callbacks = methods.length
    run_more = ()->
      while currently_running < max_parallel && next_to_run < methods.length
        index = next_to_run
        currently_running++
        next_to_run++
        do (index)->
          method_args = args_for_methods?[index] ? []
          method = methods[index]
          method method_args..., (callback_args...)->
            results[index] = callback_args
            currently_running--
            remaining_callbacks--            
            if remaining_callbacks is 0
              callback(results)
            else
              run_more()
    run_more()
              
exports = exports ? this
exports.add_util_methods = (obj)->add_util_methods(obj)
exports = add_util_methods(exports)
