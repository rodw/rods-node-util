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

    var S = require('rods-util').StringUtil;
    var hello = ' hello.  ';
    console.log(hello);         // outputs: " hello.  "
    console.log(S.trim(hello)); // outputs: "hello."

See the test suite for more examples.

## Legal Stuff

This software and associated materials are made available under the terms of the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0), an [OSD-compliant](http://www.opensource.org/licenses/Apache-2.0), non-viral, open source license. Use it in good health.

See the `license.txt` file for details.


## DATED MATERIAL FOLLOWS

The documentation below refers to a previous version of the module (published on npm as `rods-node-util`).  The package has been refactored a bit since this was written, but isn't too far off.  Until I get a chance to update these docs, you can see the test suite for up-to-date examples.

### Utility Methods

#### Util.file_to_array(filename,[options])

(Synchronously) convert the contents of the given file into to an array of lines.

    var array = Util.file_to_array('MY-FILE.TXT');

An optional "options" map can be passed as a second argument to configure the behavior of the parsing.

 * When `options.strip_blanks` is true (the default), blank lines will be excluded from the output array.

 * When `options.trim` is true (the default), leading and trailing whitespace will be removed from each line

 * When `options.comment_char` is not `null` (the default is `#`), lines for which comment character is the first *non-whitespace* character will be excluded from the output array. (Note that currently a comment that appears at the end of the line isn't recognized.  One can only comment out entire line at a time.)  E.g.,

       # this is a comment
                 # this is also a commment
       some text # this is NOT a comment

#### Util.trim(string)

Removes leading and trailing whitespace from the given string.

Both vertical (`\n`, `\r\f`, etc.) and horizonal (`\t`, ` `, etc.) whitespace are removed.

    Util.trim("\t hello  \n");          // returns "hello"

*Only* the leading and trailing whitespace is removed.  Whitespace that appears "within" the text of the string is left intact.

    Util.trim("\t hello  \n\tworld \n") // returns "hello  \n\tworld"

#### Util.object_to_array(object)

Converts an object (map) into an array of name/value pairs, one for each attribute of the object.

    var object = { foo: 'bar', height: 18, f: function() { return new Date(); } };
    var array = Util.object_to_array(object);
    console.log(array);
    // yields something like:
    // [ [ 'foo', 'bar'], [ 'height', 18 ], [ 'f', [Function] ] ]

#### Util.map_to_array(map)

Equivalent to `object_to_array`.


#### Util.object_values(object)

Returns an array containing the value of each attribute in the given object.  (Similiar to `Object#keys`, except returning values instead of keys.)


    var object = { foo: 'bar', height: 18, f: function() { return new Date(); } };
    var values = Util.object_values(object);
    console.log(values);
    // yields something like:
    // [ 'bar', 18, [Function] ]

#### Util.frequency_count(array)

Returns a map of all unique elements in the given array to the number of times they occur in the array.

    var array = [ "two", "one", "two" ]
    var freq = Util.frequency_count(array);
    console.log(freq["one"]);   // yields 1
    console.log(freq["two"]);   // yields 2
    console.log(freq["three"]); // yields null

#### Util.comparator(a,b)

Returns a negative value if `a < b`, a postive value if `a > b` and `0` if `a` and `b` are equal.

Also see `sort_by_value` and `sort_by_key`.

#### Util.sort_by_value(object,[comparator])

Returns an array of name/value pairs, one for each attribute of the given object (map), ordered by value.

An optional comparator function may be provided as the second parameter.  The default is `Util.comparator`

#### Util.sort_by_key(object,[comparator])

Returns an array of name/value pairs, one for each attribute of the given object (map), ordered by key.

An optional comparator function may be provided as the second parameter.  The default is `Util.comparator`

#### Util.async_for_loop(init,cond,act,incr,done)

Performs a generic asynchronous for loop.

Accepts five functions as parameters:

 * `initialize` - an initialization function that is called once (at the beginning of the loop). (Think `var i = 0`.)
 * `condition` - a predicate that is called before every iteration through the loop. When it returns `true`, the loop will continue.  When `false` the loop is complete (and `done` will be called). (Think `i < max`.)
 * `action` - a function implementing the "inner loop". This method should accept a single argument, a callback function that should be invoked to continue executing the loop.
 * `increment` - called after each `action` but before the corresponding call to `condition`. (Think `i++`.)
 * `done` - called at the end of the loop (after `condition` returns `false`)

Only the `action` method accepts a parameter.  Only the `condition` method returns a value.

For example, the simple loop:

    for(var i=0; i<10; i++) { console.log(i); }
    console.log("I'm done.");

could be implemented as:

    var i = 0;
    var init = function() { i = 0; };
    var cond = function() { return i < 10; };
    var actn = function(next) { console.log(i); next(); };
    var incr = function() { i = i + 1; };
    var done = function() { console.log("I'm done.");  };
    Util.async_for_loop(init,cond,actn,incr,done);

#### Util.async_for_each(list,action,,done)

Performs a generic asynchronous for-each loop.

Accepts three parameters:

 * `list` - the collection to iterate over
 * `action` - a function implementing the "inner loop" with the signature `action(value,index,list,next)`, where:
    * `value` is the current value from the list
    * `index` is the numeric index of that value (possibly null)
    * `list` is the list itself (possibly null)
    * `next` is the callback function used to continue the iteration
 * `done` - a function that is called at the end of the loop

For example:

    var list = [ 1, 2, 3, 4 ]
    actn = function(value,index,list,next) {
      console.log("The element #{value} is at position #{index}");
      next();
    }
    done = function() { }
    Util.async_for_each(list,actn,done)

#### Util.add_callback

For a given synchronous function `f`, with the signature:

    f(a,b,c,...)

returns a new function `g`, with the signature:

    g(a,b,c,...,callback)

that is equivalent to:

    callback(f(a,b,c,...));

The resulting method isn't asynchronous, but approximates the method signature and control flow used by asynchronous methods. This makes it easy to use a synchronous method where an asynchronous one is expected.

### Stopwatch

The `Stopwatch` provides a simple timer.

The `Stopwatch` can be used directly:

    var timer = Util.Stopwatch.start();
    doSomething();
    timer.stop();
    console.log("doSomething():");
    console.log(" started at ",timer.start_time);   // start_time is a Date
    console.log(" finished at ",timer.finish_time); // finish_time is a Date
    console.log(" took ",timer.elapsed_time," milliseconds."); // elapsed_time is a number (finish_time - start_time)

It can also "wrap" a synchronous method call:

    var timer = Util.Stopwatch.time_sync(doSomething);
    console.log("doSomething():");
    console.log(" started at ",timer.start_time);
    console.log(" finished at ",timer.finish_time);
    console.log(" took ",timer.elapsed_time," milliseconds.");

or an asynchronous method call:

    var report = function (timer) {
      console.log("doSomething():");
      console.log(" started at ",timer.start_time);
      console.log(" finished at ",timer.finish_time);
      console.log(" took ",timer.elapsed_time," milliseconds.");
    }
    Util.Stopwatch.time_async(doSomething,report);
