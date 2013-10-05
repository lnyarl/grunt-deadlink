###
  grunt-deadlink
  https://github.com/mage/grunt-deadlink

  Copyright (c) 2013 makdoc
  Licensed under the MIT license.
###

module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      tasks:
        expand: true
        cwd: 'src/tasks/'
        src: ['**/*.coffee']
        dest: 'tasks/'
        ext: '.js'

    clean:
      tasks: ['tmp']


  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['clean', 'coffee']
