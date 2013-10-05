module.exports = (grunt) ->
  _ = grunt.util._
  searchAllLink : (expressions, content) ->
    result = []
    _(expressions).forEach (expression) ->
      match = expression.exec content;
      while(!!match) {
        result.push match[1];
        match = expression.exec content
    result

  getFileList : (src) ->
    src = [src] if(_(src).isString())
    _(src).forEach(srcItem) -> files = files.concat(grunt.file.expand srcItem)
