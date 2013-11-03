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
          /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g  #[...]: <url>
        ]
        result = []
        _.forEach expressions, (expression) ->
          match = expression.exec content
          while(match?)
            result.push match[1]
            match = expression.exec content
        result
      maxAttempts : 3
      retryDelay : 10000
      logToFile : false
      logFilename: 'deadlink.log'
      logAll : false

    logger = new Logger options
    files = grunt.file.expand @data.src
    filter = @data.filter || options.filter
    checker = new Checker options, logger

    # getting url
    _.forEach files, (filepath) ->
      content = grunt.file.read filepath
      links = if _.isFunction filter
        filter content
      else
        util.searchAllLink filter, content

      logger.addLinkCount links.length

      _.forEach links, (link) ->
        checker.checkDeadlink filepath, link

    logger.printResult done
