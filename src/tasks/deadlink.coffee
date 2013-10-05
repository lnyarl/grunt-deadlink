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

  grunt.registerMultiTask('deadlink', 'check dead links in files.', ()->
    done = @async()

    options = this.options
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

    _.forEach files, (filepath) ->

      content = grunt.file.read(filepath)
      links = util.searchAllLink(expressions, content)
      linksCount += links.length

      _.forEach links, (link) ->
        setTimeout () ->
          option =
            method : 'HEAD'
            url : parseURL link
            strictSSL : false
            pool :
              maxSockets : 10

          request option, (error, res, body) ->
            if(res and res.statusCode == 200)
              okCount++
            else
              failCount++
              grunt.log.error "#{link} is broken (#{error ? JSON.stringify(error) : res.statusCode})"
          .setMaxListeners 25
        , 0

    st = setInterval ->
      if(linksCount == (okCount + failCount))
        grunt.log.ok "ok : #{okCount} ,fail #{failCount}"
        clearInterval st
        done()
    , 500
