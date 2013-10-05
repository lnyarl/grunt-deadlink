(function() {
  module.exports = function(grunt) {
    var _;
    _ = grunt.util._;
    return {
      searchAllLink: function(expressions, content) {
        var result;
        result = [];
        _.forEach(expressions, function(expression) {
          var match, _results;
          match = expression.exec(content);
          _results = [];
          while ((match != null)) {
            result.push(match[1]);
            _results.push(match = expression.exec(content));
          }
          return _results;
        });
        return result;
      },
      getFileList: function(src) {
        var files;
        if (_(src).isString()) {
          src = [src];
        }
        files = [];
        _.forEach(src, function(srcItem) {
          return files = files.concat(grunt.file.expand(srcItem));
        });
        return files;
      }
    };
  };

}).call(this);
