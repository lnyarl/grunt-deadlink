module.exports = (grunt) ->
  _ = grunt.util._
  fs = require('fs')
  filename = "deadlink.log"
  logger = (str) -> fs.appendFile filename, str + '\r', (err)->

  init : (toFile, logAll) ->
    @ok = grunt.log.ok if not toFile
    @error = grunt.log.error if not toFile
    if not logAll then @ok = (str)->

  ok : logger
  error : logger
