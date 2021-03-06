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

  describe 'array_to_map',->
    it 'converts an array of pairs into a map',(done)->
      a = [
        [ 'a', 'alpha' ]
        [ 'b', 'beta' ]
        [ 'g', 'gamma' ]
      ]
      map = U.array_to_map(a)
      map.a.should.equal 'alpha'
      map.b.should.equal 'beta'
      map.g.should.equal 'gamma'
      done()

    it 'converts a pair of arrays into a map',(done)->
      a = [ 'a', 'b', 'g' ]
      b = [ 'alpha', 'beta', 'gamma' ]
      map = U.array_to_map(a,b)
      map.a.should.equal 'alpha'
      map.b.should.equal 'beta'
      map.g.should.equal 'gamma'
      done()

    it 'ignores extra values when processing a pair of arrays',(done)->
      a = [ 'a', 'b', 'g' ]
      b = [ 'alpha', 'beta', 'gamma', 'omega' ]
      map = U.array_to_map(a,b)
      map.a.should.equal 'alpha'
      map.b.should.equal 'beta'
      map.g.should.equal 'gamma'
      U.count(map).should.equal 3
      done()

    it 'maps extra keys to null when processing a pair of arrays',(done)->
      a = [ 'a', 'b', 'g', 'z' ]
      b = [ 'alpha', 'beta', 'gamma' ]
      map = U.array_to_map(a,b)
      map.a.should.equal 'alpha'
      map.b.should.equal 'beta'
      map.g.should.equal 'gamma'
      U.count(map).should.equal 4
      (map.z?).should.not.be.ok
      done()

  is_even = (x)->(x%2 is 0)
  is_odd = (x)->(x%2 is 1)

  describe 'all',->
    it 'returns true iff the given predicate is true for all elements in the list',(done)->
      U.all([0,2,4,6,8],is_even).should.be.ok
      U.all([0,2,4,6,7],is_even).should.not.be.ok
      U.all([],is_even).should.be.ok
      U.all([],is_odd).should.be.ok
      done()

  describe 'any',->
    it 'returns true iff the given predicate is true for any element in the list',(done)->
      U.any([0,2,4,6,8],is_even).should.be.ok
      U.any([0,2,4,6,8],is_odd).should.not.be.ok
      U.any([0,2,4,6,7],is_even).should.be.ok
      U.any([0,2,4,6,7],is_odd).should.be.ok
      U.any([],is_even).should.not.be.ok
      U.any([],is_odd).should.not.be.ok
      done()

  describe 'none',->
    it 'returns true iff the given predicate is true for NO element in the list',(done)->
      U.none([0,2,4,6,8],is_even).should.not.be.ok
      U.none([0,2,4,6,8],is_odd).should.be.ok
      U.none([0,2,4,6,7],is_even).should.not.be.ok
      U.none([0,2,4,6,7],is_odd).should.not.be.ok
      U.none([],is_even).should.be.ok
      U.none([],is_odd).should.be.ok
      done()

  describe 'count',->

    it 'returns the number of keys in the given object',(done)->
      U.count({}).should.equal 0
      U.count({a:1}).should.equal 1
      U.count({a:1,b:2}).should.equal 2
      done()

    it 'returns the number of elements in the given array',(done)->
      U.count([]).should.equal 0
      U.count([1]).should.equal 1
      U.count([1,2]).should.equal 2
      done()

    it 'throws an exception when the given object is null',(done)->
      (()->U.count(null)).should.throw
      (()->U.count()).should.throw
      done()

    it 'throws an exception when the given object is not an object, map or array',(done)->
      (()->U.count("not a map")).should.throw
      (()->U.count(true)).should.throw
      (()->U.count(7)).should.throw
      (()->U.count(console.log)).should.throw
      done()

  describe 'shallow_merge',->

    it 'combines the properties of two maps',(done)->
      a = { property1:'alpha', property3:'gamma' }
      b = { property2:'beta' }
      c = U.shallow_merge(a,b)
      c.property1.should.equal 'alpha'
      c.property2.should.equal 'beta'
      c.property3.should.equal 'gamma'
      (b.hasOwnProperty('property1')).should.not.be.ok
      (a.hasOwnProperty('property2')).should.not.be.ok
      (b.hasOwnProperty('property3')).should.not.be.ok
      done()

    it 'overwrites properties in the first map that appear in the second',(done)->
      a = { property1:'alpha', property3:'gamma' }
      b = { property2:'beta', property3:'overwritten' }
      c = U.shallow_merge(a,b)
      c.property1.should.equal 'alpha'
      c.property2.should.equal 'beta'
      c.property3.should.equal 'overwritten'
      a.property3.should.equal 'gamma'
      b.property3.should.equal 'overwritten'
      done()

    it 'overwrites properties at the root level',(done)->
      a = { foo: { a:1, b:2} }
      b = { foo: { b:3, c:4} }
      c = U.shallow_merge(a,b)
      c.foo.hasOwnProperty('a').should.not.be.ok
      c.foo.hasOwnProperty('b').should.be.ok
      c.foo.hasOwnProperty('c').should.be.ok
      c.foo.b.should.equal 3
      c.foo.c.should.equal 4
      done()

    it 'isn\'t troubled by empty maps',(done)->
      U.count(U.shallow_merge({},{})).should.equal 0
      U.shallow_merge({a:1},{}).a.should.equal 1
      U.shallow_merge({},{a:1}).a.should.equal 1
      done()

    it 'overwrites with null',(done)->
      ((U.shallow_merge({a:1},{a:null})).a?).should.not.be.ok
      done()

    it 'supports an arbitrary number of arguments',(done)->
      a = { a:1, count:1 }
      b = { b:2, count:2 }
      c = { c:3, count:3 }
      d = { d:4, count:4 }
      e = { e:5, count:5 }
      z = U.shallow_merge(a,b,c,d,e)
      z.a.should.equal 1
      z.b.should.equal 2
      z.c.should.equal 3
      z.d.should.equal 4
      z.e.should.equal 5
      z.count.should.equal 5
      z = U.shallow_merge({},a,{},b,{},{},c,d,{},e,{})
      z.a.should.equal 1
      z.b.should.equal 2
      z.c.should.equal 3
      z.d.should.equal 4
      z.e.should.equal 5
      z.count.should.equal 5
      done()

  describe 'merge',->

    it 'combines the properties of two maps',(done)->
      a = { property1:'alpha', property3:'gamma' }
      b = { property2:'beta' }
      c = U.merge(a,b)
      c.property1.should.equal 'alpha'
      c.property2.should.equal 'beta'
      c.property3.should.equal 'gamma'
      (b.hasOwnProperty('property1')).should.not.be.ok
      (a.hasOwnProperty('property2')).should.not.be.ok
      (b.hasOwnProperty('property3')).should.not.be.ok
      done()

    it 'overwrites properties in the first map that appear in the second',(done)->
      a = { property1:'alpha', property3:'gamma' }
      b = { property2:'beta', property3:'overwritten' }
      c = U.merge(a,b)
      c.property1.should.equal 'alpha'
      c.property2.should.equal 'beta'
      c.property3.should.equal 'overwritten'
      a.property3.should.equal 'gamma'
      b.property3.should.equal 'overwritten'
      done()

    it 'merges nested properties ',(done)->
      a = { foo: { a:1, b:2} }
      b = { foo: { b:3, c:4} }
      c = U.merge(a,b)
      c.foo.hasOwnProperty('a').should.be.ok
      c.foo.hasOwnProperty('b').should.be.ok
      c.foo.hasOwnProperty('c').should.be.ok
      c.foo.b.should.equal 3
      c.foo.c.should.equal 4
      done()

    it 'isn\'t troubled by empty maps',(done)->
      U.count(U.merge({},{})).should.equal 0
      U.merge({a:1},{}).a.should.equal 1
      U.merge({},{a:1}).a.should.equal 1
      done()

    it 'overwrites with null',(done)->
      ((U.merge( {a:1},     {a:null}     )).a?).should.not.be.ok
      ((U.merge( {a:{b:1}}, {a:null}     )).a?).should.not.be.ok
      ((U.merge( {a:{b:1}}, {a:{b:null}} )).a.b?).should.not.be.ok
      done()

    it 'supports an arbitrary number of arguments',(done)->
      a = { foo: { a:1 }, count:1 }
      b = { foo: { b:2 }, count:2 }
      c = { foo: { c:3 }, count:3 }
      d = { foo: { d:4 }, count:4 }
      e = { foo: { e:5 }, count:5 }
      z = U.merge(a,b,c,d,e)
      z.foo.a.should.equal 1
      z.foo.b.should.equal 2
      z.foo.c.should.equal 3
      z.foo.d.should.equal 4
      z.foo.e.should.equal 5
      z.count.should.equal 5
      z = U.merge({},a,{},b,{},{},c,d,{},e,{})
      z.foo.a.should.equal 1
      z.foo.b.should.equal 2
      z.foo.c.should.equal 3
      z.foo.d.should.equal 4
      z.foo.e.should.equal 5
      z.count.should.equal 5
      done()


  describe 'deep_merge',->
    it 'is an alias for merge',(done)->
      a = { foo: { a:1, b:2} }
      b = { foo: { b:3, c:4} }
      c = U.deep_merge(a,b)
      c.foo.hasOwnProperty('a').should.be.ok
      c.foo.hasOwnProperty('b').should.be.ok
      c.foo.hasOwnProperty('c').should.be.ok
      c.foo.b.should.equal 3
      c.foo.c.should.equal 4
      done()

    it 'supports an arbitrary number of arguments',(done)->
      a = { foo: { a:1 }, count:1 }
      b = { foo: { b:2 }, count:2 }
      c = { foo: { c:3 }, count:3 }
      d = { foo: { d:4 }, count:4 }
      e = { foo: { e:5 }, count:5 }
      z = U.deep_merge(a,b,c,d,e)
      z.foo.a.should.equal 1
      z.foo.b.should.equal 2
      z.foo.c.should.equal 3
      z.foo.d.should.equal 4
      z.foo.e.should.equal 5
      z.count.should.equal 5
      z = U.deep_merge({},a,{},b,{},{},c,d,{},e,{})
      z.foo.a.should.equal 1
      z.foo.b.should.equal 2
      z.foo.c.should.equal 3
      z.foo.d.should.equal 4
      z.foo.e.should.equal 5
      z.count.should.equal 5
      done()

  describe 'is_int',->
    it 'returns true if and only if the given value is or can be parsed as an integer value',(done)->
      # an int
      U.is_int(-100).should.be.ok
      U.is_int(-1).should.be.ok
      U.is_int(0).should.be.ok
      U.is_int(1).should.be.ok
      U.is_int(1.0).should.be.ok
      U.is_int(100).should.be.ok
      U.is_int('-100').should.be.ok
      U.is_int('-1').should.be.ok
      U.is_int('0').should.be.ok
      U.is_int('1').should.be.ok
      U.is_int('100').should.be.ok
      U.is_int('1.0').should.be.ok
      # not an int
      U.is_int(NaN).should.not.be.ok
      U.is_int(true).should.not.be.ok
      U.is_int('one').should.not.be.ok
      U.is_int(3.14).should.not.be.ok
      U.is_int('3.14').should.not.be.ok
      U.is_int(null).should.not.be.ok
      # done
      done()

  describe 'is_nonnegative_int',->
    it 'returns true if and only if the given value is or can be parsed as an integer value greater than or equal to zero',(done)->
      # is
      U.is_nonnegative_int(0).should.be.ok
      U.is_nonnegative_int(0.0000).should.be.ok
      U.is_nonnegative_int(1).should.be.ok
      U.is_nonnegative_int(1.0).should.be.ok
      U.is_nonnegative_int('0').should.be.ok
      U.is_nonnegative_int('0.0000').should.be.ok
      U.is_nonnegative_int('1').should.be.ok
      U.is_nonnegative_int('1.0').should.be.ok
      # is not
      U.is_nonnegative_int(-0.0001).should.not.be.ok
      U.is_nonnegative_int(0.0001).should.not.be.ok
      U.is_nonnegative_int(-2).should.not.be.ok
      U.is_nonnegative_int('-0.0001').should.not.be.ok
      U.is_nonnegative_int('0.0001').should.not.be.ok
      U.is_nonnegative_int('-2').should.not.be.ok
      # done
      done()

  describe 'numeric_map_to_array',->

    it 'returns the array equivalent of a non-negative-integer-keyed map',(done)->
      a = U.numeric_map_to_array { '0':'a', '1':'b', '2.0':'c' }
      Array.isArray(a).should.be.ok
      a.length.should.equal 3
      a[0].should.equal 'a'
      a[1].should.equal 'b'
      a[2].should.equal 'c'
      done()

    it 'works with sparse maps',(done)->
      a = U.numeric_map_to_array { '1':'b', '3':'d' }
      Array.isArray(a).should.be.ok
      a.length.should.equal 4
      (a[0]?).should.not.be.ok
      a[1].should.equal 'b'
      (a[2]?).should.not.be.ok
      a[3].should.equal 'd'
      done()

    it 'works with empty maps',(done)->
      a = U.numeric_map_to_array { }
      Array.isArray(a).should.be.ok
      a.length.should.equal 0
      done()

    it 'returns null if precondtions aren\'t met',(done)->
      should.not.exist U.numeric_map_to_array { '-1': 'z', '0':'a', '1':'b' }
      should.not.exist U.numeric_map_to_array { 'xyzzy': 'z', '0':'a', '1':'b' }
      done()

  describe 'flatten_map',->

    it 'converts an simple map into an array of name/value pairs',(done)->
      map = { a:1, b:'two', c:null }
      flat = U.flatten_map(map)
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c'
      (flat[2][1]?).should.not.be.ok
      done()

    it 'converts a nested map into a dotted path array of name/value pairs',(done)->
      map = { a:1, b:'two', c:{ foo:'bar', d:{e:{f:'g'} } } }
      flat = U.flatten_map(map)
      flat.length.should.equal 4
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.foo'
      flat[2][1].should.equal 'bar'
      flat[3][0].should.equal 'c.d.e.f'
      flat[3][1].should.equal 'g'
      done()

    it 'treats null as null (by default)',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: null } } } }
      flat = U.flatten_map(map)
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      (flat[2][1]?).should.not.be.ok
      done()

    it 'treats null as null when options include {null:"as-null"})',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: null } } } }
      flat = U.flatten_map(map, null:'as-null')
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      (flat[2][1]?).should.not.be.ok
      done()

    it 'treats null as blank when options include {null:"as-blank"})',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: null } } } }
      flat = U.flatten_map(map, null:'as-blank')
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      flat[2][1].should.equal ''
      done()

    it 'treats arrays as maps (by default)',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,3] } } } }
      flat = U.flatten_map(map)
      flat.length.should.equal 5
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f.0'
      flat[2][1].should.equal 1
      flat[3][0].should.equal 'c.d.e.f.1'
      flat[3][1].should.equal 2
      flat[4][0].should.equal 'c.d.e.f.2'
      flat[4][1].should.equal 3
      done()

    it 'treats arrays as maps when options include {array:"as-map"}',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,3] } } } }
      flat = U.flatten_map(map)
      flat.length.should.equal 5
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f.0'
      flat[2][1].should.equal 1
      flat[3][0].should.equal 'c.d.e.f.1'
      flat[3][1].should.equal 2
      flat[4][0].should.equal 'c.d.e.f.2'
      flat[4][1].should.equal 3
      done()

    it 'treats arrays as arrays when options include {array:"as-array"}',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,3] } } } }
      flat = U.flatten_map(map,array:'as-array')
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      flat[2][1][0].should.equal 1
      flat[2][1][1].should.equal 2
      flat[2][1][2].should.equal 3
      done()

    it 'treats arrays as strings when options include {array:"as-json"} or {array:"as-string"} ',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,3] } } } }
      flat = U.flatten_map(map,array:'as-json')
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      flat[2][1].should.equal '[1,2,3]'
      flat = U.flatten_map(map,array:'as-string')
      flat.length.should.equal 3
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f'
      flat[2][1].should.equal '[1,2,3]'
      done()

    it 'supports nested arrays',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,['t','h','r','e','e']] } } } }
      flat = U.flatten_map(map)
      flat.length.should.equal 9
      flat[0][0].should.equal 'a'
      flat[0][1].should.equal 1
      flat[1][0].should.equal 'b'
      flat[1][1].should.equal 'two'
      flat[2][0].should.equal 'c.d.e.f.0'
      flat[2][1].should.equal 1
      flat[3][0].should.equal 'c.d.e.f.1'
      flat[3][1].should.equal 2
      flat[4][0].should.equal 'c.d.e.f.2.0'
      flat[4][1].should.equal 't'
      flat[5][0].should.equal 'c.d.e.f.2.1'
      flat[5][1].should.equal 'h'
      flat[6][0].should.equal 'c.d.e.f.2.2'
      flat[6][1].should.equal 'r'
      flat[7][0].should.equal 'c.d.e.f.2.3'
      flat[7][1].should.equal 'e'
      flat[8][0].should.equal 'c.d.e.f.2.4'
      flat[8][1].should.equal 'e'
      done()

    it 'throws an error when options.array or options.null is not recognized',(done)->
      map = { a:1, b:'two', c:{ d:{e:{f: [1,2,3] } } } }
      (()->U.flatten_map(map,array:'as-mitzelplik')).should.throw()
      map = { a:1, b:'two', c:{ d:{e:{f: null } } } }
      (()->U.flatten_map(map,null:'as-mitzelplik')).should.throw()
      done()

    describe 'circular reference handling',->

      it 'throws an exception by default',(done)->
        foo = { x:1 }
        bar = { y:2 }
        foo.bar = bar
        bar.foo = foo
        (()->U.flatten_map(foo)).should.throw()
        (()->U.flatten_map(bar)).should.throw()
        done()

      it 'throws an exception when options.when-circular is `throw`',(done)->
        foo = { x:1 }
        bar = { y:2 }
        foo.bar = bar
        bar.foo = foo
        (()->U.flatten_map(foo,{'when-circular':'throw'})).should.throw()
        (()->U.flatten_map(bar,{'when-circular':'throw'})).should.throw()
        done()

      it 'throws an exception when options.when-circular value is unrecognized',(done)->
        foo = { x:1 }
        (()->U.flatten_map(foo)).should.not.throw()
        (()->U.flatten_map(foo,{'when-circular':'xyzzy'})).should.throw()
        done()

      it 'ignores circular references when options.when-circular is `skip`',(done)->
        foo = { x:1 }
        bar = { y:2 }
        foo.bar = bar
        bar.foo = foo
        flat_foo = U.flatten_map(foo,{'when-circular':'skip'})
        flat_foo.length.should.equal 2
        flat_foo[0][0].should.equal 'x'
        flat_foo[0][1].should.equal 1
        flat_foo[1][0].should.equal 'bar.y'
        flat_foo[1][1].should.equal 2
        flat_bar = U.flatten_map(bar,{'when-circular':'skip'})
        flat_bar.length.should.equal 2
        flat_bar[0][0].should.equal 'y'
        flat_bar[0][1].should.equal 2
        flat_bar[1][0].should.equal 'foo.x'
        flat_bar[1][1].should.equal 1
        done()

      it 'isn\'t bothered by duplicates, just circular references ',(done)->
        foo = { x:1 }
        bar = { y:2, foo:foo, also:{foo:foo} }
        flat_bar = U.flatten_map(bar,{'when-circular':'throw'})
        flat_bar.length.should.equal 3
        flat_bar[0][0].should.equal 'y'
        flat_bar[0][1].should.equal 2
        flat_bar[1][0].should.equal 'foo.x'
        flat_bar[1][1].should.equal 1
        flat_bar[2][0].should.equal 'also.foo.x'
        flat_bar[2][1].should.equal 1
        done()

      it 'handles circular references nested in maps',(done)->
        d = { name:'d' }
        c = { name:'c', next:d }
        b = { name:'b', next:c }
        a = { name:'a', next:b }
        d.next = a
        flat = U.flatten_map(a,{'when-circular':'skip'})
        flat.length.should.equal 4
        flat[0][0].should.equal 'name'
        flat[0][1].should.equal 'a'
        flat[1][0].should.equal 'next.name'
        flat[1][1].should.equal 'b'
        flat[2][0].should.equal 'next.next.name'
        flat[2][1].should.equal 'c'
        flat[3][0].should.equal 'next.next.next.name'
        flat[3][1].should.equal 'd'
        done()

      it 'handles circular references nested in arrays',(done)->
        d = [ 'd' ]
        c = [ 'c', d ]
        b = [ 'b', c ]
        a = [ 'a', b ]
        d.push(a)
        flat = U.flatten_map(a,{'when-circular':'skip','array':'as-map'})
        flat.length.should.equal 4
        flat[0][0].should.equal '0'
        flat[0][1].should.equal 'a'
        flat[1][0].should.equal '1.0'
        flat[1][1].should.equal 'b'
        flat[2][0].should.equal '1.1.0'
        flat[2][1].should.equal 'c'
        flat[3][0].should.equal '1.1.1.0'
        flat[3][1].should.equal 'd'
        done()

      it 'handles circular references nested in maps and arrays',(done)->
        d = [ 'd' ]
        c = [ 'c', {next:d} ]
        b = [ 'b', {next:c} ]
        a = [ 'a', {next:b} ]
        d.push({next:a})
        flat = U.flatten_map(a,{'when-circular':'skip','array':'as-map'})
        flat.length.should.equal 4
        flat[0][0].should.equal '0'
        flat[0][1].should.equal 'a'
        flat[1][0].should.equal '1.next.0'
        flat[1][1].should.equal 'b'
        flat[2][0].should.equal '1.next.1.next.0'
        flat[2][1].should.equal 'c'
        flat[3][0].should.equal '1.next.1.next.1.next.0'
        flat[3][1].should.equal 'd'
        done()

      it 'handles circular references nested in maps and arrays (alt case)',(done)->
        d = [ 'd' ]
        c = [ 'c', {next:d} ]
        b = [ 'b', {next:c} ]
        a = [ 'a', {next:b} ]
        d.push({next:a})
        flat = U.flatten_map(c,{'when-circular':'skip','array':'as-map'})
        flat.length.should.equal 4
        flat[0][0].should.equal '0'
        flat[0][1].should.equal 'c'
        flat[1][0].should.equal '1.next.0'
        flat[1][1].should.equal 'd'
        flat[2][0].should.equal '1.next.1.next.0'
        flat[2][1].should.equal 'a'
        flat[3][0].should.equal '1.next.1.next.1.next.0'
        flat[3][1].should.equal 'b'
        done()

    it 'returns null when given null',(done)->
      array = U.flatten_map(null)
      should.not.exist(array)
      done()

  describe 'unflatten_map',->

    it 'is the inverse of flatten_map (no option case)',(done)->
      original = { a:1, b:'two', c:{ d:{e:{f: ['x','y','z'] } } } }
      flattened = U.flatten_map(original)
      unflattened = U.unflatten_map(flattened)
      unflattened.a.should.equal 1
      unflattened.b.should.equal 'two'
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      unflattened.c.d.e.f[1].should.equal 'y'
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'is the inverse of flatten_map (option.array:"as-map" case)',(done)->
      options = {array:'as-map'}
      original = { a:1, b:'two', c:{ d:{e:{f: ['x','y','z'] } } } }
      flattened = U.flatten_map(original,options)
      unflattened = U.unflatten_map(flattened,options)
      unflattened.a.should.equal 1
      unflattened.b.should.equal 'two'
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      unflattened.c.d.e.f[1].should.equal 'y'
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'is the inverse of flatten_map (option.array:"as-string" case)',(done)->
      options = {array:'as-string'}
      original = { a:1, b:'two', c:{ d:{e:{f: ['x','y','z'] } } } }
      flattened = U.flatten_map(original,options)
      unflattened = U.unflatten_map(flattened,options)
      unflattened.a.should.equal 1
      unflattened.b.should.equal 'two'
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      unflattened.c.d.e.f[1].should.equal 'y'
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'is the inverse of flatten_map (option.array:"as-json" case)',(done)->
      options = {array:'as-json'}
      original = { a:1, b:'two', c:{ d:{e:{f: ['x','y','z'] } } } }
      flattened = U.flatten_map(original,options)
      unflattened = U.unflatten_map(flattened,options)
      unflattened.a.should.equal 1
      unflattened.b.should.equal 'two'
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      unflattened.c.d.e.f[1].should.equal 'y'
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'is the inverse of flatten_map (option.array:"as-array" case)',(done)->
      options = {array:'as-array'}
      original = { a:1, b:'two', c:{ d:{e:{f: ['x','y','z'] } } } }
      flattened = U.flatten_map(original,options)
      unflattened = U.unflatten_map(flattened,options)
      unflattened.a.should.equal 1
      unflattened.b.should.equal 'two'
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      unflattened.c.d.e.f[1].should.equal 'y'
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'is the inverse of flatten_map (option.null:"as-blank" case)',(done)->
      options = {null:'as-blank'}
      original = { a:1, b:'', c:{ d:{e:{f: ['x','','z'] } } } }
      flattened = U.flatten_map(original,options)
      unflattened = U.unflatten_map(flattened,options)
      unflattened.a.should.equal 1
      (unflattened.hasOwnProperty('b')).should.be.ok
      (unflattened.b?).should.not.be.ok
      unflattened.c.d.e.f.length.should.equal 3
      unflattened.c.d.e.f[0].should.equal 'x'
      (unflattened.c.d.e.f[1]?).should.not.be.ok
      unflattened.c.d.e.f[2].should.equal 'z'
      done()

    it 'converts an array of name/value pairs into a map',(done)->
      array = [ ['a',1], ['b','two'], ['c',null] ]
      map = U.unflatten_map(array)
      map.a.should.equal 1
      map.b.should.equal 'two'
      map.hasOwnProperty('c').should.be.ok
      (map.c?).should.not.be.ok
      done()

    it 'converts dotted names into nested maps',(done)->
      array = [ ['a',1], ['b','two'], ['c.d','e'] ]
      map = U.unflatten_map(array)
      map.a.should.equal 1
      map.b.should.equal 'two'
      map.c.d.should.equal 'e'
      done()

    it 'handles multi-element nested maps properly',(done)->
      array = [ ['a',1], ['b','two'], ['c.foo','bar'], ['c.d.e.f','g'], ['c.d.x.y',1], ['c.d.x.z',2] ]
      map = U.unflatten_map(array)
      map.a.should.equal 1
      map.b.should.equal 'two'
      map.c.foo.should.equal 'bar'
      map.c.d.e.f.should.equal 'g'
      map.c.d.x.y.should.equal 1
      map.c.d.x.z.should.equal 2
      done()

    it 'converts numeric keys into arrays (by default)',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f.0','x'], ['c.d.e.f.1','y'], ['c.d.e.f.2','z'] ]
      map = U.unflatten_map(array)
      map.a.should.equal 1
      map.b.should.equal 'two'
      map.c.d.e.f.length.should.equal 3
      map.c.d.e.f[0].should.equal 'x'
      map.c.d.e.f[1].should.equal 'y'
      map.c.d.e.f[2].should.equal 'z'
      done()

    it 'converts numeric keys into arrays when options inlclude {array:"as-map"}',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f.0','x'], ['c.d.e.f.1','y'], ['c.d.e.f.2','z'] ]
      map = U.unflatten_map(array,{array:'as-map'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      map.c.d.e.f.length.should.equal 3
      map.c.d.e.f[0].should.equal 'x'
      map.c.d.e.f[1].should.equal 'y'
      map.c.d.e.f[2].should.equal 'z'
      done()

    it 'doesn\'t convert numeric keys into arrays when options include {array:"as-string"} ',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f.0','x'], ['c.d.e.f.1','y'], ['c.d.e.f.2','z'] ]
      map = U.unflatten_map(array,{array:'as-string'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.not.be.ok
      map.c.d.e.f['0'].should.equal 'x'
      map.c.d.e.f['1'].should.equal 'y'
      map.c.d.e.f['2'].should.equal 'z'
      done()

    it 'doesn\'t convert numeric keys into arrays when options include {array:"as-json"} ',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f.0','x'], ['c.d.e.f.1','y'], ['c.d.e.f.2','z'] ]
      map = U.unflatten_map(array,{array:'as-json'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.not.be.ok
      map.c.d.e.f['0'].should.equal 'x'
      map.c.d.e.f['1'].should.equal 'y'
      map.c.d.e.f['2'].should.equal 'z'
      done()

    it 'doesn\'t convert numeric keys into arrays when options include {array:"as-array"} ',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f.0','x'], ['c.d.e.f.1','y'], ['c.d.e.f.2','z'] ]
      map = U.unflatten_map(array,{array:'as-string'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.not.be.ok
      map.c.d.e.f['0'].should.equal 'x'
      map.c.d.e.f['1'].should.equal 'y'
      map.c.d.e.f['2'].should.equal 'z'
      done()

    it 'converts array-strings into arrays when options include {array:"as-string"}',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f','["x","y","z"]'] ]
      map = U.unflatten_map(array,{array:'as-string'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.be.ok
      map.c.d.e.f[0].should.equal 'x'
      map.c.d.e.f[1].should.equal 'y'
      map.c.d.e.f[2].should.equal 'z'
      done()

    it 'converts array-strings into arrays when options include {array:"as-json"}',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f','["x","y","z"]'] ]
      map = U.unflatten_map(array,{array:'as-json'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.be.ok
      map.c.d.e.f[0].should.equal 'x'
      map.c.d.e.f[1].should.equal 'y'
      map.c.d.e.f[2].should.equal 'z'
      done()

    it 'doesn\'t convert array-strings into arrays when options include {array:"as-array"}',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f','["x","y","z"]'] ]
      map = U.unflatten_map(array,{array:'as-array'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.not.be.ok
      map.c.d.e.f.should.equal '["x","y","z"]'
      done()

    it 'preserves array values when options include {array:"as-array"}',(done)->
      array = [ ['a',1], ['b','two'], ['c.d.e.f',['x','y','z'] ] ]
      map = U.unflatten_map(array,{array:'as-array'})
      map.a.should.equal 1
      map.b.should.equal 'two'
      (Array.isArray(map.c.d.e.f)).should.be.ok
      map.c.d.e.f[0].should.equal 'x'
      map.c.d.e.f[1].should.equal 'y'
      map.c.d.e.f[2].should.equal 'z'
      done()

    it 'returns null when given null',(done)->
      map = U.unflatten_map(null)
      should.not.exist(map)
      done()

  describe 'values',->
    it 'returns an array of object values',(done)->
      obj = { alpha:1, beta:2, gamma:3, another:3 }
      obj.foo = ()->console.log("some function")
      result = U.values(obj)
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

    it 'a.k.a. object_values',(done)->
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

  describe 'keys',->
    it 'returns an array of object keys',(done)->
      obj = { alpha:1, beta:2, gamma:3, another:3 }
      obj.foo = ()->console.log("some function")
      result = U.keys(obj)
      result.length.should.equal 5
      ('alpha' in result).should.be.ok
      ('beta' in result).should.be.ok
      ('gamma' in result).should.be.ok
      ('another' in result).should.be.ok
      ('foo' in result).should.be.ok
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
