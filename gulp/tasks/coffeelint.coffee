gulp.task 'coffeelint', ->

  srcs = ['src/**/*.coffee', 'tests/**/*.coffee', 'gulp/**/*.coffee']
  gulp.src srcs
      .pipe plugins.coffeelint()
      .pipe plugins.notify (file) ->
        if file.coffeelint.success
          return false
        errors = file.coffeelint.results.map (data) ->
          "Line:" + data.lineNumber + " " + data.rule
        errors.join("\n")
        "CoffeeLint: " + file.relative + " found " + file.coffeelint.errorCount + " errors." + "\n" + errors
      .pipe plugins.coffeelint.reporter()

  if argv.watch
    gulp.watch srcs, ['coffeelint']