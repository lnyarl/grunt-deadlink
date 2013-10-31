module.exports = (grunt) ->
  _ = grunt.util._

  searchAllLink : (expressions, content) ->
    result = []
    _.forEach expressions, (expression) ->
      expression = new RegExp(expression) if !(expression instanceof RegExp)
      match = expression.exec content
      while(match?)
        result.push match[1]
        match = expression.exec content
    result

  getFileList : (src) ->
    src = [src] if(_(src).isString())
    files = []
    _.forEach src, (srcItem) ->
      files = files.concat(grunt.file.expand srcItem)
    files
