fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB     = path.join(HOMEDIR,'lib')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else LIB
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exports = exports ? this
exports.Stopwatch = require(path.join(LIB_DIR,'stopwatch')) # TODO add .Stopwatch?
exports.FileUtil = require(path.join(LIB_DIR,'file-util')).FileUtil
exports.StringUtil = require(path.join(LIB_DIR,'string-util')).StringUtil
exports.ContainerUtil = require(path.join(LIB_DIR,'container-util')).ContainerUtil
exports.FunctorUtil = require(path.join(LIB_DIR,'functor-util')).FunctorUtil
