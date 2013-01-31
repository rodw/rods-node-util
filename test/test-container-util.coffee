should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
U = require(path.join(LIB_DIR,'container-util')).ContainerUtil

# ## Tests

describe 'ContainerUtil', ->
  describe 'object_values',->
    it 'returns an array of object values',(done)->
      obj = { alpha:1, beta:2, gamma:3, another:3 }
      obj.foo = ()->console.log("some function")
      result = U.object_values(obj)
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
      result = U.object_to_array(null)
      (result?).should.not.be.ok
      done()

    it 'return attributes but not standard methods',(done)->
      obj = new Date()
      result = U.object_to_array(obj)
      result.length.should.equal 0
      obj.foo = "bar"
      result = U.object_to_array(obj)
      result.length.should.equal 1
      done()

    it 'returns an array of name/value pairs',(done)->
      obj = { alpha:1, beta:2, gamma:3 }
      result = U.object_to_array(obj)
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
      result = U.object_to_array(obj)
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

  describe 'clone',->
    it 'creates a copy of non-object types',(done)->
      objects = [ 'a string', 3, 3.14159, console.log, true, false ]
      for obj in objects
        clone = U.clone(obj)
        clone.should.equal obj
        (typeof clone).should.equal (typeof obj)
        clone.toString().should.equal obj.toString()
      done()

    it 'creates a copy of array types',(done)->
      obj = [ 1, 1, 3, 5, 8, 11, 'fib(n)', true, 3.14159, console.log ]
      clone = U.clone(obj)
      (typeof clone).should.equal (typeof obj)
      clone.toString().should.equal obj.toString()
      for x,i in obj
        clone[i].should.equal x
        clone[i].toString().should.equal x.toString()
      done()

    it 'handles null',(done)->
      ((U.clone(null))?).should.not.be.ok
      ((U.clone([null]))[0]?).should.not.be.ok
      done()

    it 'creates a copy of map (object) types',(done)->
      object_one = { a:"alpha", b:"beta" }
      clone = U.clone(object_one)
      clone.a.should.equal object_one.a
      clone.b.should.equal object_one.b
      clone.c = "gamma"
      (object_one.c?).should.not.be.ok
      clone.a = "not alpha"
      clone.a.should.not.equal object_one.a
      done()

    it 'creates a *shallow* copy',(done)->
      object_one = { a:"alpha", b:"beta" }
      object_two = { x:9, y:12 }
      array_of_numbers = [ 1, 2, 3, 4 ]
      array_of_objects = [ object_one, object_two ]
      compound_object = { list:array_of_numbers, children: array_of_objects, foo:"bar" }
      clone = U.clone(compound_object)
      clone.foo.should.equal compound_object.foo
      clone.list[0].should.equal compound_object.list[0]
      clone.children[0].should.equal compound_object.children[0]
      clone.foo = "not bar"
      clone.foo.should.not.equal compound_object.foo
      clone.list[0] = 'a new value'
      compound_object.list[0].should.equal 'a new value'
      done()

  describe 'deep_clone',->
    it 'creates a copy of non-object types',(done)->
      objects = [ 'a string', 3, 3.14159, console.log, true, false ]
      for obj in objects
        clone = U.deep_clone(obj)
        clone.should.equal obj
        (typeof clone).should.equal (typeof obj)
        clone.toString().should.equal obj.toString()
      done()

    it 'creates a copy of array types',(done)->
      obj = [ 1, 1, 3, 5, 8, 11, 'fib(n)', true, 3.14159, console.log ]
      clone = U.deep_clone(obj)
      (typeof clone).should.equal (typeof obj)
      clone.toString().should.equal obj.toString()
      for x,i in obj
        clone[i].should.equal x
        clone[i].toString().should.equal x.toString()
      done()


    it 'handles deeply nested objects',(done)->
      obj = [
        'a string',
        3,
        3.14159,
        console.log,
        false,
        [ 1, 1, 3, 5, 8, 11, 'fib(n)', true, 3.14159, console.log, { foo:'bar'} ],
        { a:1, b:[ 1, 1, 3, 5, 8, 11, 'fib(n)', true, 3.14159, console.log, { foo:'bar'} ] }
      ]
      clone = U.deep_clone(obj)
      (typeof clone).should.equal (typeof obj)
      clone.toString().should.equal obj.toString()
      for x,i in obj
        (typeof clone[i]).should.equal(typeof x)
        clone[i].toString().should.equal x.toString()
        if x instanceof Array
          for y, j in x
            (typeof clone[i][j]).should.equal(typeof y)
            clone[i][j].toString().should.equal y.toString()
        else if typeof x is 'object'
          for n, v of x
            (typeof clone[i][n]).should.equal(typeof v)
            clone[i][n].toString().should.equal v.toString()

      clone[6].b[10].foo.should.equal('bar')
      obj[6].b[10].foo.should.equal('bar')
      clone[6].b[10].foo = 'not bar'
      obj[6].b[10].foo.should.equal('bar')

      done()

    it 'handles null',(done)->
      ((U.deep_clone(null))?).should.not.be.ok
      ((U.deep_clone([null]))[0]?).should.not.be.ok
      done()

    it 'creates a copy of the given map',(done)->
      object_one = { a:"alpha", b:"beta" }
      clone = U.deep_clone(object_one)
      clone.a.should.equal object_one.a
      clone.b.should.equal object_one.b
      clone.c = "gamma"
      (object_one.c?).should.not.be.ok
      clone.a = "not alpha"
      clone.a.should.not.equal object_one.a
      done()

    it 'creates a *deep* copy of the given map',(done)->
      object_one = { a:"alpha", b:"beta" }
      object_two = { x:9, y:12 }
      array_of_numbers = [ 1, 2, 3, 4 ]
      array_of_objects = [ object_one, object_two ]
      compound_object = { list:array_of_numbers, children: array_of_objects, foo:"bar" }
      clone = U.deep_clone(compound_object)
      clone.foo.should.equal compound_object.foo
      clone.list[0].should.equal compound_object.list[0]
      clone.children[0].a.should.equal compound_object.children[0].a
      clone.foo = "not bar"
      clone.foo.should.not.equal compound_object.foo
      clone.list[0] = 'a new value'
      (compound_object.list[0]).should.not.equal 'a new value'
      clone.children[0].a = 'not alpha'
      (compound_object.children[0].a).should.not.equal 'not alpha'
      done()

    it 'copies arrays correctly',(done)->
      console.log U.clone("foo")
      console.log U.deep_clone("foo")
      console.log U.deep_clone([1,2,3,4])

      # object_one = { a:"alpha", b:"beta", c:[1,2,3,['a','b','c','d']] }
      # clone = U.deep_clone(object_one)
      # orig_as_string =
      # console.log typeof object_one.c
      # console.log object_one.c
      # console.log typeof clone.c
      # console.log clone.c
      # 1.should.equal 2
      done()

  describe 'comparator',->
    it 'returns a positive value if a > b',(done)->
      (U.comparator(2,1) > 0).should.be.ok
      (U.comparator(1,2) < 0).should.be.ok
      (U.comparator(2,2) == 0).should.be.ok
      (U.comparator('z','a') > 0).should.be.ok
      (U.comparator('a','z') < 0).should.be.ok
      (U.comparator('z','z') == 0).should.be.ok
      done()

  describe 'sort_by_value',->
    it 'returns an array of pairs, sorted by value',(done)->
      map = { a:5, e:1, f:0, c:3, b:4, d:2}
      result = U.sort_by_value(map)
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
      result = U.sort_by_key(map)
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

  # describe 'transpose function',->
  #   it 'helps sort by value, descending',(done)->
  #     map = { a:5, e:1, f:0, c:3, b:4, d:2}
  #     result = U.sort_by_value(map,U.transpose(U.comparator))
  #     result.length.should.equal(6)
  #     for pair,index in result
  #       pair[1].should.equal (5-index)
  #     done()

  describe 'frequency_count',->
    it 'returns a map of unique array elements to number of occurrences in array',(done)->
      a = [ 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 'watermelon', 'banana', 'watermelon' ]
      f = U.frequency_count(a)
      (f[0]?).should.not.be.ok
      f[1].should.equal 1
      f[2].should.equal 2
      f[3].should.equal 3
      f[4].should.equal 4
      f['watermelon'].should.equal 2
      f['banana'].should.equal 1
      (f['apple']?).should.not.be.ok
      done()
