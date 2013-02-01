class ContainerUtil

  flatten_map:(map,options={})->
    result = []
    for n,v of map
      if v?
        switch (typeof v)
          when 'null','undefined'
            result.push([n,v])
          when 'string', 'number', 'function', 'boolean'
            result.push([n,v])
          when 'object','array'
            if Array.isArray(v) or v instanceof Array
              if options?.array is 'as-array'
                result.push([n,v])
              else if options?.array is 'as-json' or options?.array is 'as-string'
                result.push([n,JSON.stringify(v)])
              else if options?.array is 'as-map' or not options?.array?
                nested = @flatten_map(v)
                for elt in nested
                  result.push ["#{n}.#{elt[0]}", elt[1]]
              else
                throw new Error("option array=\"#{options.array}\" not recognized")
            else
              nested = @flatten_map(v,options)
              for elt in nested
                result.push ["#{n}.#{elt[0]}", elt[1]]
          else
            console.warn "WARNING: Didn't expect object of type #{typeof v}."
            result.push([n,v])
      else
        if options?.null is 'as-blank'
          result.push([n,''])
        else if options?.null is 'as-null' or not options?.null?
          result.push([n,v])
        else
          throw new Error("option null=\"#{options.null}\" not recognized")
    return result

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

    return result

  # returns true if and only if `i` is or can be parsed as an integer value
  is_int:(i)->(i? and (parseFloat(i) is parseInt(i)) and not isNaN(i))

  # returns true if and only if `i` is or can be parsed as an integer value greater than or equal to zero
  is_nonnegative_int:(i)=>(@is_int(i) and parseInt(i) >= 0)

  # returns the array equivalent of a non-negative-integer-keyed map (or `null` if the map contains something other than non-negative-integer keys).
  numeric_map_to_array:(obj)=>
    if @all(@keys(obj),@is_nonnegative_int)
      result = []
      for k,v of obj
        result[parseInt(k)] = v
      return result
    else
      return null

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

  all:(list,predicate)->
    for elt in list
      return false unless predicate(elt)
    return true

  any:(list,predicate)->
    for elt in list
      return true if predicate(elt)
    return false

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
