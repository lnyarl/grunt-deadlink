module.exports = (grunt) ->
  _ = grunt.util._
  fs = require('fs')
  lineSeparator = require('os').EOL

  class Logger
    linkCount : 0
    okCount : 0
    failCount : 0
    logFilename : "deadlink.log"

    constructor : ({logToFile, logAll, logFilename}) ->
      @logFilename = logFilename if logFilename?
      if logToFile
        @resultLogger = @errorLogger = @okLogger = (msg) -> fs.appendFile @logFilename, msg + lineSeparator, (err)->
      if not logAll then @okLogger = (str)->

    okLogger : grunt.log.ok
    errorLogger : grunt.log.error
    resultLogger : grunt.log.subhead

    ok : (msg)->
      @okCount++
      @okLogger msg

    error : (msg)->
      @failCount++
      @errorLogger msg

    # I don't like this method
    addLinkCount : (count)->
      @linkCount += count

    printResult: (after)->
      st = setInterval =>
        if(@linkCount == (@okCount + @failCount))
          @resultLogger "ok : #{@okCount}, error : #{@failCount}"
          clearInterval st
          after()
      , 500

  Logger
