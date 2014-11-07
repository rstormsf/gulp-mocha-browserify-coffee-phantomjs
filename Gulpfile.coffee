gulp         = require('gulp')
requireDir = require('require-dir')
requireDir('./gulp/tasks')
gulpLoadPlugins = require 'gulp-load-plugins'

global.plugins = gulpLoadPlugins()