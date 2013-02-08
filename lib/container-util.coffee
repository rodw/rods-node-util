class ContainerUtil

  # Given one argument, converts an array of name/value pairs into a map.
  # I.e.,
  #       { a[0][0]:a[0][1], a[1][0]:a[1][1], ... }
  # Given two argument, converts an array of names and an array of values into a map.
  # I.e.,
  #       { a[0]:b[0], a[1]:b[1], ... }
  array_to_map:(a,b)->
    m = { }
    if b?
      m[e] = b[i] for e,i in a
    else
      m[e[0]] = e[1] for e,i in a
    return m

  # `shallow_merge` - returns an object merging the values of the given objects (properties in objects that appear later in the argument list will overwrite those that appear earlier)
  shallow_merge:(a,b,rest...)->
    if rest?.length > 0
      b = @shallow_merge(b,rest...)
    c = @deep_clone(a)
    for n,v of b
      c[n] = @deep_clone(v)
    return c

  # `merge` - like `shallow_merge`, but will merge nested properties (such that `merge( {a:{b:1}}, {a:{c:3}})` yields `{a:{b:1,c:3}}`
  merge:(a,b,rest...)->
    if rest?.length > 0
      b = @merge(b,rest...)
    c = @deep_clone(a)
    for n,v of b
      if c[n]? and typeof c[n] is 'object' and v? and typeof v is 'object'
        c[n] = @merge(a[n],v)
      else
        c[n] = @deep_clone(v)
    return c

  # `deep_merge` - an alias for `merge`
  deep_merge:(a,b,rest...)->@merge(a,b,rest...)

  # `count` - returns the number of properties in the given map/object; throws an exception if the argument is `null` or not an object type
  count:(map)->
    if map? and typeof map is 'object'
      return @keys(map).length
    else if not map?
      throw new Error("Expected non-null object.")
    else
      throw new Error("Expected typeof 'object', found '#{typeof map}'.")

  # `flatten_map` - converts a map/object into an array of name-value pairs.
  #
  # Nested properties (those that map to maps) are "flattened" into a "dotted path", such that there
  # will be one element in the returned array for each "leaf" value in the given map.
  #
  # For example, given:
  #
  #     var map = {
  #             'a':1,
  #             'b': {
  #               'c': 3
  #             }
  #           };
  #
  # `flatten_map(map)` will return:
  #
  #     [ [ 'a', 1 ], [ 'b.c', 3 ] ]
  #
  #  OPTIONS:
  #
  #  Use `options.array` to control the way in which array values are converted:
  #
  #   * when `as-array`, arrays are returned as actual arrays
  #   * when `as-json` or `as-string`, arrays are serialized as JSON strings
  #   * when `as-map` (the default), arrays indexes are treated like map property names
  #
  #  E.g., given the map:
  #
  #      { 'x': [ 'a', 'b', 'c' ] }
  #
  #  `flatten _map` will return:
  #
  #  * `[ [ 'x', [ 'a', 'b', 'c' ]  ] ]` when `options.array` is `as-array`
  #  * `[ [ 'x', '["a","b","c"]'  ] ]` when `options.array` is `as-json` or `as-string`
  #  * `[ [ 'x.0', 'a' ], [ 'x.1', 'b' ], [ 'x.2', 'c' ] ]`,  when `options.array` is `as-map` or undefined
  #
  #  Use `options.null` to control the way in which null values are converted:
  #   * when `as-null` (the default), `null` values are returned as `null` values
  #   * when `as-blank`, `null` values are returned as blank strings `''`
  #
  #  E.g., given the map:
  #
  #      { x: null }
  #
  #  `flatten _map` will return:
  #
  #  * `[ [ 'x', null ] ]` when `options.null` is `as-null` or undefined
  #  * `[ [ 'x', '' ] ]` when `options.null` is `as-blank`
  #
  # Also see `unflatten_map`, which reverses this operation.
  #
  flatten_map:(map,options={})->

    # check arguments. we do this here because:
    # 1. we want an exception thrown for bad arguments no matter whether the option is encountered during processing
    # 2. we want to do the checks as few times as possible
    if options? and not options?.parents?

      options.parents = [ map ]


      if options['when-circular']? and not (options['when-circular'] in ['throw','skip'])
        throw new Error "Unexpected value for options['when-circular'].  Found \"#{options['when-circular']}\"."
      if options.array? and not (options.array in ['as-array','as-json','as-string','as-map'])
        throw new Error "Unexpected value for options['array'].  Found \"#{options['array']}\"."

      if options.null? and not (options.null in ['as-null','as-blank'])
        throw new Error "Unexpected value for options['null'].  Found \"#{options['null']}\"."

    result = []
    for n,v of map
      if v?
        switch (typeof v)
          when 'null','undefined'
            result.push([n,v])
          when 'string', 'number', 'function', 'boolean'
            result.push([n,v])
          when 'object','array'
            options = options ? {}
            options.parents = options.parents ? []
            if v in options.parents
              if (not options?['when-circular']?) or (options['when-circular'] is 'throw')
                throw new Error "Found circular reference at name #{n} within #{map}."
              # else if options?['when-circular'] is 'skip'
                # ignore it and go on to the next element
              # else
              #   throw new Error "Unexpected value for options['when-circular'].  Found \"#{options['when-circular']}\"."
            else
              options.parents.push(v)
              if Array.isArray(v) or v instanceof Array
                if options?.array is 'as-array'
                  result.push([n,v])
                else if options?.array is 'as-json' or options?.array is 'as-string'
                  result.push([n,JSON.stringify(v)])
                else if options?.array is 'as-map' or not options?.array?
                  nested = @flatten_map(v,options)
                  for elt in nested
                    result.push ["#{n}.#{elt[0]}", elt[1]]
                # else
                #   throw new Error("option array=\"#{options.array}\" not recognized")
              else
                nested = @flatten_map(v,options)
                for elt in nested
                  result.push ["#{n}.#{elt[0]}", elt[1]]
              options.parents.pop()
          else
            console.warn "WARNING: Didn't expect object of type #{typeof v}."
            result.push([n,v])
      else
        if options?.null is 'as-blank'
          result.push([n,''])
        else if options?.null is 'as-null' or not options?.null?
          result.push([n,v])
        # else
        #   throw new Error("option null=\"#{options.null}\" not recognized")
    return result

  # `unflatten_map` - Converts an array of name-value pairs (like those generated by `flatten_map`) into a map.
  #
  # Property names that contain periods (`.`) are converted into nested objects
  #
  # For example, given:
  #
  #     var array = [
  #                   [ 'a', 1 ],
  #                   [ 'b.c', 3 ]
  #                 ];
  #
  # `unflatten_map(array)` will return:
  #
  #     { a:1, b:{ c:3 } }
  #
  #  OPTIONS:
  #
  #  Use `options.array` to control the way in which array values are converted:
  #
  #   * when `as-json` or `as-string`, string values that look like JSON arrays converted into arrays
  #   * when `as-map` (the default), non-negative integer attribute names are treated as array indexes (i.e, `a.0` is treated as `a[0]`)
  #   * when `as-array`, no special array handling is used (so any array values that appear in the input array pass through unchanged)
  #
  #
  #  Use `options.null` to control the way in which null values are converted:
  #
  #   * when `as-blank`, blank strings (`''`) are converted to `null`
  #   * when `as-null`, no special `null` handling is used (so any null values that appear in the input array pass through unchanged)
  #
  unflatten_map:(array,options)->
    result = {}
    for pair in array
      path = (pair[0]).split('.')
      name = path.pop()
      cur = result
      for segment in path
        cur = cur[segment] = cur[segment] ? {}
      cur[name] = pair[1]
    if options?.array?
      switch options.array
        when 'as-map'
          result = @recursive_numeric_map_to_array(result)
        when 'as-string','as-json'
          result = @recursive_array_string_to_array(result)
    else
      result = @recursive_numeric_map_to_array(result)
    if options?.null? and options.null is 'as-blank'
      result = @recursive_blank_string_to_null(result)
    return result

  # `is_int` - returns true if and only if `i` is or can be parsed as an integer value
  is_int:(i)->(i? and (parseFloat(i) is parseInt(i)) and not isNaN(i))

  # `is_nonnegative_int` - returns true if and only if `i` is or can be parsed as an integer value greater than or equal to zero
  is_nonnegative_int:(i)=>(@is_int(i) and parseInt(i) >= 0)

  # `numeric_map_to_array` - returns the array equivalent of a non-negative-integer-keyed map
  # (or `null` if the map contains something other than non-negative-integer keys).
  # (This method is primarily used internally.)
  numeric_map_to_array:(obj)=>
    if @all(@keys(obj),@is_nonnegative_int)
      result = []
      for k,v of obj
        result[parseInt(k)] = v
      return result
    else
      return null

  # `recursive_blank_string_to_null` - Given a blank string (`''`), returns null.
  # Given an object or array, returns an equivalent object or array in which each
  # value that is a blank string has been converted to `null`
  # and applies this logic recursively to any array or object values found in the given object.
  # (This method is primarily used internally.)
  recursive_blank_string_to_null:(obj)->
    if obj?
      if typeof obj is 'string' and obj is ''
        obj = null
      else if Array.isArray(obj)
        for elt,i in obj
          obj[i] = @recursive_blank_string_to_null(elt)
      else if typeof obj is 'object'
        for n,v of obj
          obj[n] = @recursive_blank_string_to_null(v)
    return obj

  # `recursive_numeric_map_to_array` - given a map composed entirely of non-negative integer keys (as strings or numbers), returns the equivalent array.
  # and applies this logic recursively to any array or object values found in the given object.
  # (This method is primarily used internally.)
  recursive_numeric_map_to_array:(obj)->
    if not obj?
      return null
    else if typeof obj is 'object'
      as_array = @numeric_map_to_array(obj)
      if as_array?
        for elt,i in as_array
          as_array[i] = @recursive_numeric_map_to_array(elt)
        return as_array
      else
        for n,v of obj
          obj[n] = @recursive_numeric_map_to_array(v)
        return obj
    else
      return obj

  # `recursive_array_string_to_array` - given a string that can be parsed as a JSON array, returns the equivalent array
  # and applies this logic recursively to any array or object values found in the given object.
  # (This method is primarily used internally.)
  recursive_array_string_to_array:(obj)->
    if not obj?
      return null
    else if typeof obj is 'string'
      if /^\s*\[.*\]\s*$/.test(obj)
        as_array = null
        try
          as_array = JSON.parse(obj)
        catch e
          as_array = null
        if as_array?
          for elt,i in as_array
            as_array[i] = @recursive_array_string_to_array(elt)
          return as_array
        else
          return obj
      else
        return obj
    else if obj instanceof Array or Array.isArray(obj)
      for elt,i in obj
        obj[i] = @recursive_array_string_to_array(elt)
      return obj
    else if typeof obj is 'object'
      for n,v of obj
        obj[n] = @recursive_array_string_to_array(v)
      return obj
    else
      return obj

  # `clone` - create a shallow copy of the given object.
  clone:(x)->
    if x?
      switch (typeof x)
        when 'null','undefined'
          return x
        when 'string', 'number', 'function', 'boolean'
          return x
        when 'object','array'
          if Array.isArray(x) or x instanceof Array
            return [].concat(x)
          else
            clone = {}
            for name,value of x
              clone[name] = value
            return clone
        else
          return x # generally shouldn't get here
    else
      return x

  # `deep_clone` - create a deep copy of the given object (recursively cloning any array or map values).
  deep_clone:(x)->
    if x?
      switch (typeof x)
        when 'null','undefined'
          return x
        when 'string', 'number', 'function', 'boolean'
          return x
        when 'object','array'
          if Array.isArray(x) or x instanceof Array
            clone = []
            for e in x
              clone.push @deep_clone(e)
            return clone
          else
            clone = {}
            for name,value of x
              clone[name] = @deep_clone(value)
            return clone
        else
          return x # generally shouldn't get here
    else
      return x

  # `all` - returns `true` iff the given `predicate` is `true` for all elements in the array `list`.
  all:(list,predicate)->
    for elt in list
      return false unless predicate(elt)
    return true

  # `any` - returns `true` iff the given `predicate` is `true` for *any* element in the array `list`.
  any:(list,predicate)->
    for elt in list
      return true if predicate(elt)
    return false

  # `none` - returns `true` iff the given `predicate` is `true` for *no* element in the array `list`.
  none:(list,predicate)->
    for elt in list
      return false if predicate(elt)
    return true

  # `object_to_array` - convert an object (map) into an array of name/value pairs
  object_to_array:(object)->
    if object?
      a = []
      for k,v of object
        a.push [k,v]
      return a
    else
      return null

  # `map_to_array` - an alias for `object_to_array`.
  map_to_array:(object)->@object_to_array(object)

  # `object_values` - an alias for `values` (for backward compatibility)
  object_values:(object)->@values(object)

  # `values` - convert an object (map) into an array of values.
  values:(object)->
    a = []
    a.push(v) for k,v of object
    return a

  # `values` - convert an object (map) into an array of keys.
  keys:(object)->
    a = []
    a.push(k) for k,v of object
    return a

  # `array_to_bag` - convert an array into a map
  # of elements to the number of times they occur
  # in the array.
  array_to_bag:(a)->
    m = {}
    for e in a
      c = m[e] ? 0
      m[e] = c + 1
    return m

  # `frequency_count` - an alias for `array_to_bag`.
  frequency_count:(a)->@array_to_bag(a)

  # `comparator` - returns a negative value if a < b, a postive value if a > b or 0 otherwise
  comparator:(a,b)->
    if a > b
      return 1
    else if a < b
      return -1
    else
      return 0

  # `sort_by_value` - return an array of name/value pairs, ordred by value.
  sort_by_value:(map,comp)->
    comp = @comparator unless comp?
    (@map_to_array(map)).sort (a,b)-> comp(a[1], b[1])

  # `sort_by_key` - return an array of name/value pairs, ordred by name.
  sort_by_key:(map,comp)->
    comp = @comparator unless comp?
    (@map_to_array(map)).sort (a,b)-> comp(a[0], b[0])

exports = exports ? this
exports.ContainerUtil = new ContainerUtil()
