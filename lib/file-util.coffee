fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
StringUtil = require(path.join(LIB_DIR,'string-util')).StringUtil

class FileUtil

  file_to_string_sync:(filename,encoding)->fs.readFileSync(filename,encoding).toString()

  file_to_string:(filename,encoding,callback)->
    if typeof encoding is 'function' && !callback?
      callback = encoding
    fs.readFile filename,encoding,(err,data)->callback(err,data?.toString())

  file_to_array_sync:(filename,options)->
    return StringUtil.string_to_array(@file_to_string_sync(filename,options?.encoding),options)

exports = exports ? this
exports.FileUtil = new FileUtil()
