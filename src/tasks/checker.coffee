module.exports = (grunt) ->
  parseURL = (require 'url').parse
  request = require 'request'

  class Checker
    logger : null

    constructor : ({retryDelay, maxAttempts}, logger)->
      @retryDelay = retryDelay
      @maxAttempts = maxAttempts
      @logger = logger

    isAllowedStatusCode : (code) ->
      code = parseInt code
      ([200].indexOf code) >= 0

    isRetryCode : (code) ->
      (["ETIMEOUT",  "ECONNREFUSED", "HPE_INVALID_CONSTANT"].indexOf code) >= 0

    checkDeadlink : (filepath, link, retryCount = 0) ->
      requestOption =
        method : 'GET'
        url : parseURL link
        strictSSL : false
        followRedirect : true
        pool :
          maxSockets : 10
        timeout: 60000

      retryDelay = if retryCount? then 0 else @retryDelay
      setTimeout =>
        request requestOption, (error, res, body) =>
          if res? and @isAllowedStatusCode res.statusCode
            @logger.ok "ok: #{link} at #{filepath}"
          else if error? and @isRetryCode error.code and retryCount < @maxAttempts
            @logger.error "retry: #{link} (#{retryCount}) at #{filepath}"
            @checkDeadlink filepath, link, retryCount
          else
            msg = if error then JSON.stringify error else res.statusCode
            @logger.error "broken: #{link} (#{msg}) at #{filepath}"
        .setMaxListeners 25
      , retryDelay

  Checker
