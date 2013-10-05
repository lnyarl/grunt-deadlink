/*
  grunt-deadlink
  https://github.com/mage/grunt-deadlink

  Copyright (c) +2013 makdoc
  Licensed under the MIT license.
*/


(function() {
  module.exports = function(grunt) {
    var parseURL, request, util, _;
    request = require('request');
    parseURL = (require('url')).parse;
    util = (require('./util'))(grunt);
    _ = grunt.util._;
    return grunt.registerMultiTask('deadlink', 'check dead links in files.', function() {
      var done, expressions, failCount, files, linksCount, okCount, options, run, st;
      done = this.async();
      options = this.options({
        expressions: [/\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g, /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g]
      });
      files = util.getFileList(this.data.src);
      expressions = this.data.expressions || options.expressions;
      linksCount = okCount = failCount = 0;
      run = function(link, retryCount) {
        var option, time;
        option = {
          url: parseURL(link),
          strictSSL: false,
          followRedirect: true,
          pool: {
            maxSockets: 10
          },
          maxAttempts: 3,
          retryDelay: 10000,
          timeout: 100000
        };
        time = retryCount != null ? 0 : option.retryDelay;
        return setTimeout(function() {
          return request(option, function(error, res, body) {
            var msg;
            if ((res != null) && res.statusCode === 200) {
              return okCount++;
            } else if ((error != null) && error.code === "ECONNREFUSED" && retryCount < option.maxAttempts) {
              grunt.log.error("" + link + " is retring (" + retryCount + ")");
              retryCount++;
              return run(option, link, retryCount);
            } else {
              failCount++;
              msg = error ? JSON.stringify(error) : "" + res.statusCode;
              return grunt.log.error("" + link + " is broken (" + msg + ")");
            }
          }).setMaxListeners(25);
        }, time);
      };
      _.forEach(files, function(filepath) {
        var content, links;
        content = grunt.file.read(filepath);
        links = util.searchAllLink(expressions, content);
        linksCount += links.length;
        return _.forEach(links, function(link) {
          return run(link);
        });
      });
      return st = setInterval(function() {
        if (linksCount === (okCount + failCount)) {
          grunt.log.ok("ok : " + okCount + " ,fail " + failCount);
          clearInterval(st);
          return done();
        }
      }, 500);
    });
  };

}).call(this);
