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

  # returns a negative value if a < b, a postive value if a > b or 0 otherwise
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

exports = exports ? this
exports = add_util_methods(exports)
