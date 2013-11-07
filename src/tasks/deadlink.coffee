###
  grunt-deadlink
  https://github.com/lnyarl/grunt-deadlink

  Copyright (c) +2013 choi yongjae
  Licensed under the MIT license.
###

module.exports = (grunt) ->
  util = (require './util')(grunt)
  Logger = (require './logger')(grunt)
  Checker = (require './checker')(grunt)
  _ = grunt.util._

  grunt.registerMultiTask 'deadlink', 'check dead links in files.', ->
    done = @async()

    options = @options
      # this expression can changed to recognizing other url format.
      # eg. markdown, wiki syntax, html
      # markdown is default
      filter: (content)->
        expressions = [
          /\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g, #[...](<url>)
          /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g,  #[...]: <url>

          #/\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g, #[...](<url>)
          #/\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g,  #[...]: <url>
          #/((\.?\.?\/?[a-zA-Z\.\-_])+)/g
        ]
        util.searchAllLink expressions, content
      maxAttempts : 3
      retryDelay : 60000
      logToFile : false
      logFilename: 'deadlink.log'
      logAll : false

    files = grunt.file.expand @data.src
    filter = @data.filter || options.filter
    logger = new Logger options
    checker = new Checker options, logger

    logger.progress()
    util.extractURL files, filter, (filepath, link) ->
        logger.increaseLinkCount()
        checker.checkDeadlink filepath, link

    logger.printResult done
