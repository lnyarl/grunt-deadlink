module.exports = function(grunt) {
  var _ = grunt.util._;
  return {
    searchAllLink : function(expressions, content) {
      _(expressions).forEach(function(expression) {
        var match = expression.exec(content);
        while(!!match) {
          console.log(filepath + " : " + match.index + " : " + match[1]);
          match = expression.exec(match.input.substr(match.index));
        }
      });
    }

  };
};
