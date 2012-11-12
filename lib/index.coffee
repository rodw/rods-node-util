fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

exports = exports ? this

Util = require(path.join(LIB_DIR,'rods-node-util'))
Util.add_util_methods(exports)

Stopwatch = require(path.join(LIB_DIR,'stopwatch'))
exports.Stopwatch = Stopwatch
