module.exports = (grunt) ->
  _ = grunt.util._

  searchAllLink : (expressions, content) ->
    result = []
    _.forEach expressions, (expression) ->
      (grunt.log.fatal "filter's type must be RegExp or function") if !(_.isRegExp expression)
      match = expression.exec content
      while(match?)
        result.push match[1]
        match = expression.exec content
    result
