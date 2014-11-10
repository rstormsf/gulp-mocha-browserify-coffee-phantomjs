browserify = require 'browserify'
source = require 'vinyl-source-stream'
path = require 'path'
coffeeify = require 'coffeeify'
minifyify = require 'minifyify'
uglifyify = require 'uglifyify'
buffer = require 'vinyl-buffer'
exorcist   = require('exorcist')

gulp.task 'dist',['coffeelint'], ->
  brOpts =
    fullPaths: true
    extensions: ['.coffee']
    paths: [path.resolve './src']
    debug: true

  b = browserify brOpts
  b.add './src/code.coffee'
  b.transform(coffeeify)

  minOpts =
    map: 'bundled.min.js.map'
    output: './dist/bundled.min.js.map'
    minify: false
  b.plugin "minifyify", minOpts
  b.bundle()
    .pipe source 'bundled.min.js'
    .pipe gulp.dest './dist'