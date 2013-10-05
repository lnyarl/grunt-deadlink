###
  grunt-deadlink
  https://github.com/mage/grunt-deadlink

  Copyright (c) +2013 makdoc
  Licensed under the MIT license.
###

module.exports = (grunt) ->

  request = require 'request'
  parseURL = (require 'url').parse
  util = (require './util')(grunt)
  _ = grunt.util._

  grunt.registerMultiTask 'deadlink', 'check dead links in files.', ->
    done = @async()

    options = @options
      # this expression can changed to recognizing other url format.
      # eg. markdown, wiki syntax, html
      # markdown is default
      expressions: [
        /\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g, #[...](<url>)
        /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g  #[...]: <url>
      ]

    files = util.getFileList @data.src
    expressions = @data.expressions || options.expressions
    linksCount = okCount = failCount = 0
    run = (link, retryCount) ->
      option =
        url : parseURL link
        strictSSL : false
        followRedirect : true
        pool :
          maxSockets : 10
        maxAttempts : 3
        retryDelay : 10000
        timeout: 100000
      time = if retryCount? then 0 else option.retryDelay
      setTimeout ->
        request option, (error, res, body) ->
          if(res? and res.statusCode == 200)
            okCount++
          else if(error? and error.code == "ECONNREFUSED" and retryCount < option.maxAttempts)
            grunt.log.error "#{link} is retring (#{retryCount})"
            retryCount++
            run(option, link, retryCount)
          else
            failCount++
            msg = if error then JSON.stringify error else (""+res.statusCode)
            grunt.log.error "#{link} is broken (#{msg})"
        .setMaxListeners 25
      , time

    _.forEach files, (filepath) ->

      content = grunt.file.read(filepath)
      links = util.searchAllLink(expressions, content)
      linksCount += links.length

      _.forEach links, (link) ->
        run link

    st = setInterval ->
      if(linksCount == (okCount + failCount))
        grunt.log.ok "ok : #{okCount} ,fail #{failCount}"
        clearInterval st
        done()
    , 500
