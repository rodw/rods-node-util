class FunctorUtil

  # PREDICATES
  ##############################################################################

  # returns a predicate that is the union of the given predicates (true iff all given predicates are true)
  and:(predicates...)->
    predicates = predicates[0] if (predicates? && typeof predicates[0] isnt 'function' && predicates.length is 1)
    return (params...)->
      for predicate in predicates
        if !(predicate(params...))
          return false
      return true

  # returns a predicate that is the intersection of the given predicates (false iff all of the given predicates are false)
  or:(predicates...)->
    predicates = predicates[0] if (predicates? && typeof predicates[0] isnt 'function' && predicates.length is 1)
    return (params...)->
      for predicate in predicates
        if predicate(params...)
          return true
      return false

  # returns a predicate that is true iff exactly one of the given predicates if true
  xor:(predicates...)->
    predicates = predicates[0] if (predicates? && typeof predicates[0] isnt 'function' && predicates.length is 1)
    return (params...)->
      found_true = false
      for predicate in predicates
        if predicate(params...)
          if found_true
            return false
          else
            found_true = true
      return found_true

  # returns a predicate that is the negation of the given predicate (true iff the given predicate is false)
  not:(predicate)->return (params...)->not(predicate(params...))

  # constant true
  true:()->true

  # constant false
  false:()->false

  # FUNCTIONS
  ##############################################################################

  # given f(a,b) returns f(b,a)
  transpose_arguments: (f)->return (a,b,rest...)->f(b,a,rest...)

  # given f(a,b,...,z) returns f(z,...,b,a)
  reverse_arguments: (f)->return (p...)->f((p.reverse())...)

  # returns f(g())
  compose_two:(f,g)->
    if !f?
      return g
    else if !g?
      return f
    else
      return (params...)->
        return f(g(params...))

  # returns f0(f1(f2(....fn()...)))
  compose:(functions...)->
    functions = functions[0] if (functions? && typeof functions[0] isnt 'function' && functions.length is 1)
    g = functions.pop()
    g = @compose_two(functions.pop(),g) while functions.length > 0
    return g

  # `for` - A functor based for-loop.
  #
  # Accepts 5 function-valued parameters:
  #  * `initialize` - an initialization function (no arguments passed, no return value is expected)
  #  * `condition` - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned)
  #  * `action` - the action to take (no arguments passed, no return value is expected)
  #  * `step` - called at the end of every `action`, prior to `condition`  (no arguments passed, no return value is expected)
  #  * `whendone` - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected)
  #
  # This method largely exists for symmetry with `for_async`.
  for:(init,cond,action,step,done)->
    init() if init?
    while cond()
      action() if action?
      step() if step?
    done() if done?

  # `for_async` - Executes an asynchronous for loop.
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
  #     for_async(init,cond,actn,incr,done)
  #
  for_async:(initialize,condition,action,increment,whendone)->
    looper = ()->
      if condition()
        action ()->
          increment()
          looper()
      else
        whendone() if whendone?
    initialize()
    looper()

  # `for_each` - A functor based forEach loop.
  #
  # Accepts 3 parameters:
  #  * `list` - the array to iterate over
  #  * `action` - the function with the signature (value,index,list) indicating the action to take
  #  * `whendone` - called at the end of the loop
  #
  # This method doesn't add much value over the built-in Array.forEach, but exists for symmetry with `for_each_async`.
  for_each:(list,action,done)->
    list.forEach(action) if list? && action?
    done() if done?

  # `for_each_async` - Executes an asynchronous forEach loop.
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
  #     for_each_async [0..10], (elt,index,array,next)->
  #       console.log elt
  #       next()
  #
  for_each_async:(list,action,whendone)->
    i = m = null
    init = ()-> i = 0;
    cond = ()-> (i < list.length)
    incr = ()-> i += 1
    act  = (next)-> action(list[i],i,list,next)
    @for_async(init, cond, act, incr, whendone)


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
  add_callback: (f)->
    return (args...)=>
      callback = args.pop()
      callback(f(args...))

  fork:(methods, args_for_methods, callback)->
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

  throttled_fork: (max_parallel, methods, args_for_methods, callback)->
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
exports.FunctorUtil = new FunctorUtil()
