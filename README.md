# Rod's Node.js Utilities

A small library of utility functions and classes, primarily intended for use within server-side JavaScript (CoffeeScript).

## Installation

The module is published as `rods-util` on npm.  It has no (runtime) external dependencies.

You can install rods-util directly through `npm`:

    npm install rods-util -g

(omit the `-g` flag to install the module in a local `node_modules` directory rather than the global one).

or by adding it as a dependency in your `package.json`:

    "dependencies": { "rods-util": "latest" }

## Use

To use the module, simply require it:

```javascript
var S = require('rods-util').StringUtil;
var hello = ' hello.  ';
console.log(hello);         // outputs: " hello.  "
console.log(S.trim(hello)); // outputs: "hello."
```

See the test suite for more examples.

## Documentation

The module is divided into several independent collections of utility methods.

Currently (as of version 0.4.0) there are five collections:

1. ***ContainerUtil*** - provides utility methods that operate on containers like Arrays and Maps.

2. ***FileUtil*** - provides utility methods that operate on Files and related objects.

3. ***FunctorUtil*** - provides utility methods that manipulate functions and support function-oriented programming. (Here is where you'll find things like function composition, asynchronous loops, etc.)

4. ***Stopwatch*** - is a simple timer that can be used to time synchronous and asynchronous activities.

5. ***StringUtil*** - provides utility methods that operate on Strings.

Each is described in more detail below.

(These documents *may* be incomplete or slightly out-of-date. See the test suite (`./test/*.coffee`) for more examples and/or a more comprehensive and up-to-date description.)

### ContainerUtil

`ContainerUtil` provides utility methods that operate on containers like Arrays and Maps.

#### Importing

To import the `ContainerUtil`:

```javascript
var CU = require('rods-util').ContainerUtil;
```

#### Methods

##### clone(map)

Creates a (shallow) copy of a map or object.

Example:

```javascript
var original = { a: 1, b: 'two' };
var clone = CU.clone(original);

console.log('original.a is',original.a); // outputs: "original.a is 1"
console.log('clone.a is',clone.a);       // outputs: "clone.a is 1"

clone.a = 2
console.log('original.a is',original.a); // outputs: "original.a is 1"
console.log('clone.a is',clone.a);       // outputs: "clone.a is 2"
```

##### deep_clone(map)

Creates a (deep) copy of a map or object.

Example:

```javascript
var original = { a: 1, b: 'two', c: { x:'alpha', y:'beta' } };
var clone = CU.deep_clone(original);
console.log('original.c.x is',original.c.x); // outputs: "original.c.x is alpha"
console.log('clone.c.x is',clone.c.x);       // outputs: "clone.c.x is alpha"
clone.c.x = 'gamma'
console.log('original.c.x is',original.c.x); // outputs: "original.c.x is alpha"
console.log('clone.c.x is',clone.c.x);       // outputs: "clone.c.x is gamma"
```

##### object_to_array(obj)

Creates an array of name/value pairs from an object or map.

Example:

```javascript
var m = { a: 1, b: 'two' };
var a = CU.object_to_array(m);
console.log(a); // outputs:  [ ['a',1], ['b','two'] ]
```

##### map_to_array(obj)

An alias for `object_to_array` (which see).

##### object_values(obj)

Convert an object (map) into an array of values.

Example:

```javascript
var m = { a: 1, b: 'two' };
var a = CU.object_vales(m);
// Array a is now:  [ 1, 'two' ]
```

##### frequency_count

Converts an array into a map whose keys are the unique elements in the array and whose values are the number of times the element appears in array.

Example:

```javascript
var a = [ 'a', 'b', 'c', 'b', 'c', 'b' ];
var c = CU.frequency_count(a);
console.log(c); // outputs: { a:1, b:3, c:2 }
```

##### sort_by_value

Converts a map into an array of name/value pairs, ordered by value.

Example:

```javascript
var m = { a:2, c:1, b:3 };
var a = CU.sort_by_value(m);
console.log(a); // outputs: [ ['c',1], ['a',2], ['b',3] ]
```

##### sort_by_key

Converts a map into an array of name/value pairs, ordered by name (key).

Example:

```javascript
var m = { a:2, c:1, b:3 };
var a = CU.sort_by_key(m);
console.log(a); // outputs: [ ['a',2], ['b',3], ['c',1] ]
```


### FileUtil

`FileUtil` provides utility methods that operate on files and related objects

#### Importing

To import the `FileUtil`:

```javascript
var FU = require('rods-util').FileUtil;
```

#### Methods

##### file_to_string(filename,[encoding],callback)

Read the file at `filename` into a string.

```javascript
var callback = function(err,contents) {
  if(err) {
    // an error occured
  } else {
    // process contents
  }
};
FU.file_to_string('MY-FILE.TXT',callback);
```

##### file_to_string_sync(filename,[encoding])

A synchronous version of `file_to_string`.

```javascript
var contents = FU.file_to_string_sync('MY-FILE.TXT');
```

##### file_to_array(filename,options)

A convenience method that combines `FileUtil.file_to_string` and `StringUtil.string_to_array`.

```javascript
var callback = function(err,lines) {
  if(err) {
    // an error occured
  } else {
    // process lines
  }
};
FU.file_to_array('MY-FILE.TXT',callback);
```

Note that the `options` map may contain an encoding as well as the various options supported by `string_to_array` (which see).

##### file_to_array_sync(filename,options)

A synchronous version of `file_to_array`.

```javascript
var lines = FU.file_to_array_sync('MY-FILE.TXT');
```

### FunctorUtil

#### Importing

To import the `FunctorUtil`:

```javascript
var FnU = require('rods-util').FunctorUtil;
```

#### Predicate Methods

Predicate methods provide utilties that operate on predicates (functions that return a boolean (`true`/`false`) value).

##### true()

Returns a function that yields a constant `true`:

```javascript
var predicate = FnU.true();
console.log( predicate() ); // outputs: true
```

##### false()

Returns a function that yields a constant `false`:

```javascript
var predicate = FnU.false();
console.log( predicate() ); // outputs: false
```

##### not(predicate)

Returns a function that yields the opposite of the given predicates.

```javascript
var yes = FnU.true();
var predicate = FnU.not(yes);
console.log( predicate() ); // outputs: false
```

##### and(predicates...)

Returns a function that yields `true` if and only if all the given predicates yield `true`.

```javascript
var p1 = FnU.true();
var p2 = FnU.false();
var p3 = FnU.true();
var predicate = FnU.and( p1, p2, p3 );
console.log( predicate() ); // outputs: false
var another = FnU.and( p1, p3 );
console.log( another() ); // outputs: true
```

##### or(predicates...)

Returns a function that yields `true` if *any* of the given predicates yield `true`.

```javascript
var p1 = FnU.true();
var p2 = FnU.false();
var p3 = FnU.false();
var predicate = FnU.or( p1, p2, p3 );
console.log( predicate() ); // outputs: true
var another = FnU.and( p2, p3 );
console.log( another() ); // outputs: false
```

##### xor(predicates...)

Returns a function that yields `true` if *exactly one* of the given predicates yield `true`.

```javascript
var p1 = FnU.true();
var p2 = FnU.false();
var p3 = FnU.true();
var p4 = FnU.false();
var predicate = FnU.or( p1, p2, p4 );
console.log( predicate() ); // outputs: true
var another = FnU.and( p1, p2, p3 );
console.log( another() ); // outputs: false
```

#### Function Methods

Function methods provide utilties that operate on functions.

##### transpose_arguments(function)

Given a function `f(a,b)` returns a function equivalent to `f(b,a)`.

Note that any arguments after the first two remain unchanged.

##### reverse_arguments(function)

Given a function `f(a,b,c,...,z)` returns a function equivalent to `f(z,...c,b,a)`.

##### compose(function,function,...)

Given the functions `f` and `g`, returns a function equivalent to `f(g())`.

Given the functions `f`, `g` and `h`, returns a function equivalent to `f(g(h()))`, and so on.

##### for(init,condition,action,step,whendone)

Provides a functor-based for-loop.

Accepts 5 function-valued parameters:

 * *init* - an initialization function (no arguments passed, no return value is expected)
 * *condition* - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned)
 * *action* - the action to take in each pas through the loop (no arguments passed, no return value is expected)
 * *step* - called at the end of every `action`, prior to `condition`  (no arguments passed, no return value is expected)
 * *whendone* - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected).

This method largely exists for symmetry with `for_async`.

##### for_async(init,condition,action,step,whendone)

Executes an asynchronous for-loop.

Accepts 5 function-valued parameters:

 * *init* - an initialization function (no arguments passed, no return value is expected)
 * *condition* - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned)
 * *action* - the action to take in each pas through the loop (no arguments passed, no return value is expected)
 * *step* - called at the end of every `action`, prior to `condition`  (no arguments passed, no return value is expected)
 * *whendone* - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected).

For example, the loop:

```javascript
for(var i=0; i<10; i++) { console.log(i); }
```

Could be implemented as:

```javascript
var i = 0;
init = function() { i = 0; };
cond = function() { return i < 10; };
actn = function(next) { console.log(i); next(); };
incr = function() { i = i + 1; };
done = function() { };
for_async(init,cond,actn,incr,done);
```

##### for_each(list,action,whendone)

Provides a functor-based for-each-loop.

Accepts 3 parameters:

 * *list* - the array to iterate over
 * *action* - the function indicating the action to take (with the signature `(value,index,list)`)
 * *whendone* - called at the end of the loop

This method doesn't add much value over the built-in `Array.forEach`, but exists for symmetry with `for_each_async`.

##### for_each_async(list,action,whendone)

Executes an asynchronous for-each loop.

Accepts 3 parameters:

 * *list* - the array to iterate over
 * *action* - the function indicating the action to take (with the signature `(value,index,list)`)
 * *whendone* - called at the end of the loop

This method largely exists for symmetry with `for_each_async`.

For example, the loop

```coffeescript
[0..10].foreach (elt,index,array)-> console.log elt
```

(That's in CoffeeScript, not JavaScript.)

Could be implemented as:

```coffeescript
for_each_async [0..10], (elt,index,array,next)->
  console.log elt
  next()
```

##### add_callback(function)

For a given synchronous function `f(a,b,c,...)`, returns a new function `g(a,b,c,...,callback)` that is equivalent to `callback(f(a,b,c,...))`.

The resulting method isn't asynchronous, but approximates the method signature and control flow  used by asynchronous methods. This makes it easy to use a synchronous method where an asynchronous one is expected.

##### fork(methods,args_for_methods,callback)

Invokes each of the given asynchronous `methods` immediately (passing the corresponding `args_for_methods`, if any), and collects the response from each.

When all methods have invoked their callbacks, the specified `callback` is invoked, passing an array containing the callback arguments from each method.

For example:

```coffeescript
sum       = (a,b,callback)->callback(a+b)
product   = (a,b,callback)->callback(a*b)
identity  = (a,b,callback)->callback(a,b)

methods   = [ sum, product, identity ]
arguments = [ [ 3, 4], [ 3, 4 ], [ 3, 4 ] ]

FnU.fork methods, arguments, (results)->
 console.log results[0] # yields: 7
 console.log results[1] # yields: 12
 console.log results[3] # yields: [ 3, 4 ]
```

(That's in CoffeeScript, not JavaScript.)

##### throttled_fork(max,methods,args_for_methods,callback)

Just like `fork`, but ensures no more than `max` of the methods are running at the same time.

### StringUtil

#### trim(string)

Removes leading and trailing whitespace from the given string.

Both vertical (`\n`, `\r\f`, etc.) and horizonal (`\t`, ` `, etc.) whitespace are removed.

```javascript
var S = require('rods-util').StringUtil;
S.trim("\t hello  \n"); // returns "hello"
```

*Only* the leading and trailing whitespace is removed.  Whitespace that appears "within" the text of the string is left intact.

```javascript
S.trim("\t hello  \n\tworld \n"); // returns "hello  \n\tworld"
```

#### strip_comment(str)

Equivalent to `comment_stripper('#','\\')`, which see.

#### comment_stripper(comment_char,[escape_char])

Returns a function that will strip (inline) comments of the specified format from input strings.

The `comment_char` and all subsquent characters (thru the end of the string) will be removed.

An instance of `comment_char` that is immediately proceeded by `escape_char` will be treated as a literal `comment_char`.  (Other instances of `escape_char` will be treated as a literal `escape_char`.)

Example:

```javascript
var S = require('rods-util').StringUtil;
var f = S.comment_stripper('%','}');
f("This is text. % This is comment."); // returns ""This is text. "
f("25}% of 20 is 5");                  // returns "25% of 20 is 5"
```

The `StringUtil.strip_comment` method is a comment stripper with `#` as the comment delimiter, and `\` as the escape character.  (Note that since `\` is JavaScript's escape character, you must write `"\\"` to pass `"\"`. E.g.: `f = S.comment_stripper('#','\\')` will create a comment stripper with a single backslash as the escape character.

#### escape_for_regexp(str)

Returns a representation of `str` that can be passed to the `RegExp` constructor in order to match the literal sequence found in `str`.

Example:

```javascript
var S = require('rods-util').StringUtil;
var dot_paren = S.escape_for_regexp('.)'); // returns `\.\)`
var re = new RegExp('^[A-Z]'+dot_paren)    // returns /^[A-Z]\.\)/
re.test("A.)")                             // returns true
re.test("A\.\)")                           // returns false
```

#### is_blank(str)

Returns `true` if the given string is `null`, empty (`""`) or only contains whitespace characters.

#### isnt_blank(str)

Returns `true` if the given string is not `null`, not empty (`""`) and contains at least one non-whitespace character.

#### string_to_array(str,[options])

Splits a string into an array of strings with various configurable options.

* `options.delimiter` - a pattern on which to split the string (defaults to `/[\n\r\f\v]/`)
* `options.comment_char` - when present (and not `false`) this and all subsequent characters (up to the next delimiter) will be stripped (defaults to `'#'`)
* `options.comment_char_escape` - when present, a character than can be used to "escape" a literal comment character (defaults to a single backslash).
* `options.trim` - when `true`, remove leading and trailing whitespace characters from each "line" (defaults to `true`)
* `options.strip_blanks` - when true, remove empty lines from the returned array (defaults to `true`)

For example, given a string `str` such as:

    Line 1

    Line 3 # with a comment
      Line 4
    # Line 5 is all comment
    Line 6 has an \# escaped comment.

then:

```javascript
var S = require('rods-util').StringUtil;
S.string_to_array(str);
```

will yield:

    Line 1
    Line 3
      Line 4
    Line 6 has an # escaped comment.

## Legal Stuff

This software and associated materials are made available under the terms of the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0), an [OSD-compliant](http://www.opensource.org/licenses/Apache-2.0), non-viral, open source license. Use it in good health.

See the `license.txt` file for details.
