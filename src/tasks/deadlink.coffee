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
  logger = (require './logger')(grunt)
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
      toFile : false
      logAll : false

    logger.init options.toFile, options.logAll
    files = util.getFileList @data.src
    expressions = @data.expressions || options.expressions
    linksCount = okCount = failCount = 0
    allowdStatusCode = 200

    run = (filepath, link, retryCount) ->
      option =
        method : 'GET'
        url : parseURL link
        strictSSL : false
        followRedirect : true
        pool :
          maxSockets : 10
        timeout: 60000

      time = if retryCount? then 0 else options.retryDelay
      setTimeout ->
        request option, (error, res, body) ->
          if(res? and res.statusCode == allowdStatusCode) # allowdStatusCode = 200
            okCount++
            logger.ok "ok: #{link} at #{filepath}"
          else if(error? and (error.code == "ECONNREFUSED" or error.code == "HPE_INVALID_CONSTANT") and retryCount < options.maxAttempts)
            logger.error "retry: #{link} (#{retryCount}) at #{filepath}"
            retryCount++
            run filepath, link, retryCount
          else
            failCount++
            msg = if error then JSON.stringify error else (""+res.statusCode)
            logger.error "broken: #{link} (#{msg}) at #{filepath}"
        .setMaxListeners 25
      , time

    _.forEach files, (filepath) ->

      content = grunt.file.read(filepath)

      links = if typeof options.filter == 'function' then options.filter(content) else util.searchAllLink(options.filter, content)
      linksCount += links.length

      _.forEach links, (link) ->
        run filepath, link, 0

    st = setInterval ->
      if(linksCount == (okCount + failCount))
        grunt.log.ok "ok : #{okCount} ,fail #{failCount}"
        clearInterval st
        done()
    , 500
