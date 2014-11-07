gulp = require 'gulp'
browserify = require 'browserify'
watchify = require 'watchify'
coffeeify = require 'coffeeify'
source = require 'vinyl-source-stream'
glob = require 'glob'
path = require 'path'
mocaccino = require 'mocaccino'
subarg = require 'subarg'
phantom = require '../phantom_helper'
browserSync = require 'browser-sync'
through = require 'through2'
opts = subarg(process.argv.slice(2))

gulp.task 'run-tests', ->
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
  b.add specs

  unless opts.watch
    opts.output = through()
    opts.reporter = 'spec'
    opts.phantomjs ?= './node_modules/phantomjs/bin/phantomjs'
    b.plugin phantom, opts

  b.plugin mocaccino, {
    reporter : opts.reporter or 'html'
    ui       : opts.ui or 'bdd'
    node     : opts.node
    yields   : 250
    timeout  : 2000000000000
    grep     : opts.grep
    invert   : opts.invert
  }

  syncStarted = false
  b.on 'bundle', (bundle) ->
    bundle.on 'end', ->
      unless syncStarted and opts.watch
        browserSync
          server:
            baseDir: 'www'
          notify: false
        syncStarted = true
        return

  bundle = ->
    if (!bundling) 
      bundling = true
      b.bundle()
       .pipe source 'bundled.js'
       .pipe gulp.dest './www'
       .pipe(browserSync.reload({stream: true}))
    else 
      queued = true  
  if opts.watch
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

gulp.task 'default', ['run-tests']
