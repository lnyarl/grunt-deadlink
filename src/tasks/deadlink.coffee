###
  grunt-deadlink
  https://github.com/lnyarl/grunt-deadlink

  Copyright (c) +2013 choi yongjae
  Licensed under the MIT license.
###

module.exports = (grunt) ->

  request = require 'request'
  parseURL = (require 'url').parse
  util = (require './util')(grunt)
  Logger = (require './logger')(grunt)
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
    files = util.getFileList @data.src
    filter = @data.filter || options.filter
    allowedStatusCode = 200

    checkDeadlink = (filepath, link, retryCount) ->
      requestOption =
        method : 'GET'
        url : parseURL link
        strictSSL : false
        followRedirect : true
        pool :
          maxSockets : 10
        timeout: 60000

      retryDelay = if retryCount? then 0 else options.retryDelay
      setTimeout ->
        request requestOption, (error, res, body) ->
          if(res? and res.statusCode == allowedStatusCode)
            logger.ok "ok: #{link} at #{filepath}"
          else if(error? and (error.code == "ETIMEOUT" or error.code == "ECONNREFUSED" or error.code == "HPE_INVALID_CONSTANT") and retryCount < options.maxAttempts)
            logger.error "retry: #{link} (#{retryCount}) at #{filepath}"
            run filepath, link, retryCount
          else
            msg = if error then JSON.stringify error else res.statusCode
            logger.error "broken: #{link} (#{msg}) at #{filepath}"
        .setMaxListeners 25
      , retryDelay

    # getting url
    _.forEach files, (filepath) ->
      content = grunt.file.read filepath
      links = if typeof options.filter == 'function' 
        options.filter content
      else
        util.searchAllLink options.filter, content

      logger.addLinkCount links.length

      _.forEach links, (link) ->
        checkDeadlink filepath, link, 0

    logger.printResult done
