gulp = require 'gulp'
browserify = require 'browserify'
watchify = require 'watchify'
coffeeify = require 'coffeeify'
source = require 'vinyl-source-stream'
glob = require 'glob'
path = require 'path'
mocaccino = require 'mocaccino'
phantom = require '../phantom_helper'
browserSync = require 'browser-sync'
through = require 'through2'

gulp.task 'run-tests',['coffeelint'], ->
  brOpts =
    fullPaths: true
    extensions: ['.coffee']
    paths: [path.resolve './src']
    debug: true
    cache: {}
    packageCache: {}

  b = browserify brOpts

  b.transform(coffeeify)
  specs = glob.sync('./tests/specs/**.coffee').map (componentsDir) ->
    path.resolve componentsDir
  b.add './tests/helper.coffee'
  b.add specs

  unless argv.watch
    argv.output = through()
    argv.reporter = 'spec'
    argv.phantomjs ?= './node_modules/phantomjs/bin/phantomjs'
    b.plugin phantom, argv

  b.plugin mocaccino, {
    reporter : argv.reporter or 'html'
    ui       : argv.ui or 'bdd'
    node     : argv.node
    yields   : 250
    timeout  : 2000000000000
    grep     : argv.grep
    invert   : argv.invert
  }

  b.on 'bundle', (bundle) ->
    bundle.on 'end', ->
      unless browserSync.active and argv.watch
        browserSync
          server:
            baseDir: 'debug'
          notify: false
          files: ["debug/*.js"]
          tunnel: argv.tunnel and argv.watch
          online: true
          minify: false
        return

  bundle = ->
    if (!bundling)
      bundling = true
      b.bundle()
        .pipe source 'bundled.js'
        .pipe gulp.dest './debug'
        .pipe(browserSync.reload({stream: true}))
    else
      queued = true
  if argv.watch
    w = watchify(b)
    bundling = false
    queued = false
    
    w.on 'update', bundle
    b.on 'bundle', (out) ->
      out.on 'end', ->
        bundling = false
        if (queued)
          queued = false
          setImmediate(bundle)
  bundle()