/*
 * grunt-deadlink
 * https://github.com/mage/grunt-deadlink
 *
 * Copyright (c) +2013 makdoc
 * Licensed under the MIT license.
 */

'use strict';


module.exports = function(grunt) {
  var util = require('./util')(grunt);
  var _ = grunt.util._;
  grunt.registerMultiTask('deadlink', 'check dead links in files.', function() {
    var done = this.async();

    var options = this.options({
      // this expression can changed to recognizing other url format.
      // eg. markdown, wiki syntax, html
      expressions: [
                   /\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g,
                   /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g
                   ],
      ignore:[]
    });

    var files = [];
    // get Files
    _(this.data.src).forEach(function(src) {
      var expaned = grunt.file.expand(src);
      files = files.concat(expaned);
    });

    var request = require('request');
    var parseURL = require('url').parse;


    //var ignore = this.data.ignore || options.ignore;
    var expressions = this.data.expressions || options.expressions;
    var linksCount = 0;
    var okCount = 0;
    var failCount = 0;

    _(files).forEach(function(filepath) {
      var content = grunt.file.read(filepath);
      var links = util.searchAllLink(expressions, content);
      linksCount += links.length;
      _(links).forEach(function(link){
        setTimeout(function(){
          var parsedURL = parseURL(link);
          var option = {
            method : 'HEAD',
            url : parsedURL,
            strictSSL : false,
            pool : {
              maxSockets : 10
            }
          };
          request(option, function(error, res, body){
            if(res && res.statusCode == 200) {
              okCount++;
            }
            else {
              failCount++;
              grunt.log.error(link + " is broken(" + (error ? JSON.stringify(error) : res.statusCode) + ")");
            }
          }).setMaxListeners(25);
        }, 0);
      });
    });

    var st = setInterval(function(){
      if(linksCount == (okCount + failCount)) {
        grunt.log.ok("ok : " + okCount + " ,fail : " + failCount);
        clearInterval(st);
        done();
      }
    }, 300);
  });

};
