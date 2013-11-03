module.exports = (grunt) ->
  _ = grunt.util._
  fs = require('fs')
  lineSeparator = require('os').EOL

  class Logger
    linkCount : 0
    okCount : 0
    failCount : 0
    passCount : 0
    logFilename : "deadlink.log"

    constructor : ({logToFile, logAll, logFilename}) ->
      @logFilename = logFilename if logFilename?
      if logToFile
        @passCount = @resultLogger = @errorLogger = @okLogger = (msg) -> fs.appendFile @logFilename, msg + lineSeparator, (err)->
      if not logAll then @okLogger = (str)->

    okLogger : grunt.verbose.ok
    errorLogger : grunt.verbose.error
    resultLogger : grunt.log.subhead
    passLogger : grunt.verbose.writeln

    pass : (msg)->
      @passCount++
      @passLogger msg

    ok : (msg)->
      @okCount++
      @okLogger msg

    error : (msg)->
      @failCount++
      @errorLogger msg

    # I don't like this method
    increaseLinkCount : ()->
      @linkCount++

    printResult: (after)->
      st = setInterval =>
        if(@linkCount == (@okCount + @failCount + @passCount))
          @resultLogger "ok : #{@okCount}, error : #{@failCount}, pass : #{@passCount}"
          clearInterval st
          after()
      , 500

  Logger
