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

The following is a description of *some* of the methods available within this package.

See the test suite (`./test/*.coffee`) for more examples.

### FileUtil

#### file_to_string(filename,[encoding],callback) / file_to_string_sync(filename,[encoding])

Read the file at `filename` into a string.

```javascript
var F = require('rods-util').FileUtil
str = file_to_string_sync('MY-FILE.TXT');
```

#### file_to_array_sync(filename,options)

A convenience method that combines `FileUtil.file_to_string_sync` and `StringUtil.string_to_array`.

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
