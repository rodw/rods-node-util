class ContainerUtil
  clone:(map)->
    clone = {}
    for name,value of map
      clone[name] = value
    return clone

  deep_clone:(map)->
    clone = {}
    for name,value of map
      if typeof value is 'array' || typeof value is 'object'
        clone[name] = @deep_clone(value)
      else
        clone[name] = value
    return clone

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

  # `object_values` - convert an object (map) into an array of values.
  # Also see `Object.keys`.
  object_values:(object)->
    a = []
    for k,v of object
      a.push v
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
