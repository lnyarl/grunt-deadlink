# grunt-deadlink

> check dead links in files

## Getting Started
This plugin requires Grunt `~0.4.1`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-deadlink --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-deadlink');
```

## The "deadlink" task

### Overview
In your project's Gruntfile, add a section named `deadlink` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  deadlink: {
    options: {
      expressions: [...] // regular expression to take a link. default is markdown.
    },
    your_target: {
      src: [...]         // grunt file expand syntax. files path for testing.
      expressions: [...] // regular expression to recognize a link. default is markdown. It has high priority then options.
    },
  },
})
```

### Options

#### options.toFile
- Type : `boolean`
- Default value : false

If this is true, broken link list is printed to the file. watch file 'deadlink.log'. It will locate in same directory with Gruntfile.js

#### options.logAll
- Type : `boolean`
- Default value : false

If this is true, living link (non-broken) is logged. It can used with `options.toFile`

#### target.src
- `Required`
- Type : `String/Array`

grunt file expand syntax.i It indicate files that include links for testing it is dead or not.

#### target.expressions
- Type: `Array of RegExp object`
- Default value : [ /\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g, /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g ]

regular expression to recognize a link. default is markdown. It has high priority then options.


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

