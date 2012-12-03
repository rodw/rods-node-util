fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FunctorUtil = require(path.join(LIB_DIR,'functor-util')).FunctorUtil

# LOCAL METHODS
#
# We need (or at least want) to use these methods in the *declaration* of the
# class below, so we declare them as (file) local variables.

# See StringUtil.escape_for_regexp
escape_for_regexp=(str)->
  return str.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")

# See StringUtil.strip_comment, StringUtil.comment_stripper
make_comment_stripper=(comment_char,escape_char)->
  comment_char = escape_for_regexp(comment_char)
  escape_char = escape_for_regexp(escape_char) if escape_char?
  escaped_re = new RegExp(escape_char+comment_char,'g') if escape_char?
  comment_re = new RegExp('(^[^'+comment_char+']*)'+comment_char)
  return (str)->
    re_assemble = []
    parts = str.split(escaped_re)
    for part in parts
      match = part.match(comment_re)
      if match?
        if match[1]?
          re_assemble.push(match[1])
        return re_assemble.join(comment_char)
      else
        re_assemble.push(part)
    return re_assemble.join(comment_char)

############################################################

class StringUtil

  # Remove any leading or trailing whitespace from the given string.
  trim:(str)->return str?.replace(/^\s\s*/, '').replace(/\s\s*$/, '')
  comment_stripper:make_comment_stripper
  strip_comment:make_comment_stripper("#","\\")
  escape_for_regexp:escape_for_regexp

  # Returns true iff the given string is non-null and contains non-whitespace characters.
  isnt_blank:(str)->return (str? && /\w/.test(str))

  # Returns true iff the given string is null, empty or only contains whitespace characters.
  is_blank:(str)=>not(@isnt_blank(str))

  # Splits a string into an array of strings (with various configurable options).
  #
  # - options.delimiter - pattern on which to split string (defaults to /[\n\r\f\v])
  # - options.comment_char - when present (and not false) this and all subsequent characters (up to the end of the "line") will be stripped (defaults to '#')
  # - options.comment_char_escape - when present, a character than can be used to "escape" a a literal comment character (defaults to '\' but you'll need to write that as '\\')
  # - options.trim - when present, remove leading and trailing whitespace characters from each "line" (defaults to `true`)
  # - options.strip_blanks - when present, remove empty lines from the returned array (defaults to `true`)
  string_to_array:(str,options)->
    options = {}  unless options?
    options.delimiter           = /[\n\r\f\v]/ unless options.trim?
    options.comment_char        = '#'          unless options.comment_char?
    options.comment_char_escape = '\\'         unless options.comment_char_escape?
    options.trim                = true         unless options.trim?
    options.strip_blanks        = true         unless options.strip_blanks?

    a = str.split(options.delimiter)

    # we compose the two mapping functions (when present) so we only have to iterate the list once on a.map()
    mapper = null
    if options.comment_char? && options.comment_char isnt false
      mapper = FunctorUtil.compose(@comment_stripper(options.comment_char,options.comment_char_escape,mapper))
    if options.trim
      mapper = FunctorUtil.compose(@trim,mapper)
    a = a.map(mapper) if mapper?

    if options.strip_blanks
      a = a.filter(@isnt_blank)
    return a

exports = exports ? this
exports.StringUtil = new StringUtil()
