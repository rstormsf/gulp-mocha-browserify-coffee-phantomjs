global.gulp         = require('gulp')
requireDir = require('require-dir')
requireDir('./gulp/tasks')
gulpLoadPlugins = require 'gulp-load-plugins'
global.fs = require 'fs'
subarg = require 'subarg'
global.argv = subarg(process.argv.slice(2))


global.plugins = gulpLoadPlugins()