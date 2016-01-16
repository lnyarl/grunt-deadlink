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
    progressBar : null

    constructor : ({logToFile, logAll, logFilename}) ->
      @logFilename = logFilename if logFilename?
      if logToFile
        @passLogger = @resultLogger = @errorLogger = @okLogger = (msg) -> fs.appendFile @logFilename, msg + lineSeparator, (err)->
      if not logAll
        @okLogger = (str)->
        @passLogger = (str)->

    okLogger : grunt.verbose.ok
    errorLogger : grunt.verbose.error
    resultLogger : grunt.log.subhead
    passLogger : grunt.verbose.ok

    pass : (msg)->
      @passCount++
      @progressBar.tick() if @progressBar?
      @passLogger msg

    ok : (msg)->
      @okCount++
      @progressBar.tick() if @progressBar?
      @okLogger msg

    error : (msg)->
      @failCount++
      @progressBar.tick() if @progressBar?
      @errorLogger msg

    progress : ()->
      return if grunt.option('verbose')
      ProgressBar = require('progress')
      @progressBar = new ProgressBar '[:bar]:percent :elapsed',
        total: 0
        complete: '#'
        incomplete: ' '
        width: 40

    # I don't like this method
    increaseLinkCount : ()->
      @linkCount++
      @progressBar.total = @linkCount if @progressBar?

    printResult: (onSuccess, onFail)->
      st = setInterval =>
        if(@linkCount == (@okCount + @failCount + @passCount))
          @resultLogger "ok : #{@okCount}, error : #{@failCount}, pass : #{@passCount}"
          clearInterval st
          if @failCount == 0
            onSuccess()
          else
            onFail(@failCount)
      , 500

  Logger
