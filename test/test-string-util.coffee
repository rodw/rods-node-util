should = require 'should'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
U = require(path.join(LIB_DIR,'string-util')).StringUtil

describe "StringUtil",->

  describe 'trim',->
    it "strips leading and trailing whitespace",(done)->
      U.trim(" ").should.equal ""
      U.trim(" x ").should.equal "x"
      U.trim("\t\nx\n").should.equal "x"
      U.trim("\t\nx\t y\n").should.equal "x\t y"
      U.trim("a b c d").should.equal "a b c d"
      U.trim("\n\na\n\nb\n").should.equal "a\n\nb"
      (U.trim(null)?).should.not.be.ok
      done()

  describe 'strip_comment',->
    it "strips characters following the specified character",(done)->
      U.strip_comment('# The quick brown fox jumped.').should.equal ''
      U.strip_comment('The #quick brown fox jumped.').should.equal 'The '
      U.strip_comment('The quick brown # fox jumped.').should.equal 'The quick brown '
      U.strip_comment('T#he quick brown fox jumped.').should.equal 'T'
      U.strip_comment('The ## quick brown fox jumped.').should.equal 'The '
      U.strip_comment('The # # qu# ick brown fox jumped.').should.equal 'The '
      U.strip_comment('The quick brown fox jumped.').should.equal 'The quick brown fox jumped.'
      done()

    it "unless escaped",(done)->
      U.strip_comment("\\#The quick brown fox jumped.").should.equal '#The quick brown fox jumped.'
      U.strip_comment("The \\#quick brown fox jumped.").should.equal 'The #quick brown fox jumped.'
      U.strip_comment("The \\#quick brown # fox jumped.").should.equal 'The #quick brown '
      U.strip_comment("The \\\\#quick brown # fox jumped.").should.equal "The \\#quick brown "
      done()

    it "doesn't require an escape character",(done)->
      f = U.comment_stripper('#')
      f("\\#The quick brown fox jumped.").should.equal '\\'
      f("#The quick brown fox jumped.").should.equal ''
      f("The quick brown #fox jumped.").should.equal 'The quick brown '
      done()

  describe 'string_to_array',->
    it 'should split a string into an array of lines',(done)->
      result = U.string_to_array(DATA,{ strip_blanks: false, comment_char:false, trim: false, delimiter:/[\n\r\f]/ })
      expected = [ 'This is line 1.',
                   'This is line 2.',
                   '# Line 3 is a comment.',
                   'This is line 4. # Line 4 is followed by a comment.',
                   '   Line 5 has leading whitespace.',
                   '   # Line 6 has leading whitespace before a comment.',
                   'Line 7 tries to escape a commment, like this: \\# see?',
                   '',
                   'This is line 9.  Line 8 was blank.',
                   '#',
                   'This is line 11. Line 10 was just a comment char.' ]
      for line in expected
        (result.shift()).should.equal line
      result.length.should.equal 0
      done()

    it 'should strip comments when specified',(done)->
      result = U.string_to_array(DATA,{ strip_blanks: false, comment_char:'#', comment_char_escape:'\\',trim: false, delimiter:/[\n\r\f]/ })
      expected = [ 'This is line 1.',
                   'This is line 2.',
                   '',
                   'This is line 4. ',
                   '   Line 5 has leading whitespace.',
                   '   ',
                   'Line 7 tries to escape a commment, like this: # see?',
                   '',
                   'This is line 9.  Line 8 was blank.',
                   '',
                   'This is line 11. Line 10 was just a comment char.' ]
      for line in expected
        (result.shift()).should.equal line
      result.length.should.equal 0
      done()

    it 'should trim whitespace when asked',(done)->
      result = U.string_to_array(DATA,{ strip_blanks: false, comment_char:'#', comment_char_escape:'\\',trim: true, delimiter:/[\n\r\f]/ })
      expected = [ 'This is line 1.',
                   'This is line 2.',
                   '',
                   'This is line 4.',
                   'Line 5 has leading whitespace.',
                   '',
                   'Line 7 tries to escape a commment, like this: # see?',
                   '',
                   'This is line 9.  Line 8 was blank.',
                   '',
                   'This is line 11. Line 10 was just a comment char.' ]
      for line in expected
        (result.shift()).should.equal line
      result.length.should.equal 0
      done()

    it 'should skip blank lines when asked',(done)->
      result = U.string_to_array(DATA,{ strip_blanks: true, comment_char:'#', comment_char_escape:'\\',trim: true, delimiter:/[\n\r\f]/ })
      expected = [ 'This is line 1.',
                   'This is line 2.',
                   'This is line 4.',
                   'Line 5 has leading whitespace.',
                   'Line 7 tries to escape a commment, like this: # see?',
                   'This is line 9.  Line 8 was blank.',
                   'This is line 11. Line 10 was just a comment char.' ]
      for line in expected
        (result.shift()).should.equal line
      result.length.should.equal 0
      done()

  # describe 'file_to_array',->
  #   DATA_FILE = path.join(__dirname,'data_file.txt')

    # it 'should read a file into an array of lines',(done)->
    #   result = Util.file_to_array(DATA_FILE,{})
    #   expected = [
    #     'line 1',
    #     '  line 2   ',
    #     '# line 3 is a comment',
    #     'line 4',
    #     '',
    #     ' # line 6 is a comment',
    #     'line 7  ',
    #     ''
    #   ]
    #   for line in expected
    #     line.should.equal result.shift()
    #   result.length.should.equal 0
    #   done()

  #   it 'should trim, skip blanks and skip # comments by default',(done)->
  #     result = Util.file_to_array(DATA_FILE)
  #     expected = [
  #       'line 1',
  #       'line 2',
  #       'line 4',
  #       'line 7'
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()

  #   it 'should trim when asked',(done)->
  #     result = Util.file_to_array(DATA_FILE,{trim:true})
  #     expected = [
  #       'line 1',
  #       'line 2',
  #       '# line 3 is a comment',
  #       'line 4',
  #       '',
  #       '# line 6 is a comment',
  #       'line 7',
  #       ''
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()

  #   it 'should trim and skip comments when asked',(done)->
  #     result = Util.file_to_array(DATA_FILE,{trim:true,comment_char:'#'})
  #     expected = [
  #       'line 1',
  #       'line 2',
  #       'line 4',
  #       '',
  #       'line 7',
  #       ''
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()

  #   it 'should allow custom comment chars',(done)->
  #     result = Util.file_to_array(DATA_FILE,{comment_char:'l'})
  #     expected = [
  #       '# line 3 is a comment',
  #       '',
  #       ' # line 6 is a comment',
  #       ''
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()

  #   it 'should strip blanks when asked',(done)->
  #     result = Util.file_to_array(DATA_FILE,{strip_blanks:true})
  #     expected = [
  #       'line 1',
  #       '  line 2   ',
  #       '# line 3 is a comment',
  #       'line 4',
  #       ' # line 6 is a comment',
  #       'line 7  '
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()

  #   it 'should trim and strip blanks when asked',(done)->
  #     result = Util.file_to_array(DATA_FILE,{strip_blanks:true,trim:true})
  #     expected = [
  #       'line 1',
  #       'line 2',
  #       '# line 3 is a comment',
  #       'line 4',
  #       '# line 6 is a comment',
  #       'line 7'
  #     ]
  #     for line in expected
  #       line.should.equal result.shift()
  #     result.length.should.equal 0
  #     done()
DATA =
"""
This is line 1.
This is line 2.
# Line 3 is a comment.
This is line 4. # Line 4 is followed by a comment.
   Line 5 has leading whitespace.
   # Line 6 has leading whitespace before a comment.
Line 7 tries to escape a commment, like this: \\# see?

This is line 9.  Line 8 was blank.
#
This is line 11. Line 10 was just a comment char.
"""

# console.log DATA
