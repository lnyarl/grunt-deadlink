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
For example, check out below code.

```js
grunt.initConfig({
  deadlink: {
    options: {
      filter: function(content) { // `function` or `regular expressions` to take a link. default is markdown.
          var expressions = [
            /\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g,  //[...](<url>)
            /\[[^\]]*\]\s*:\s*(http[s]?:\/\/.*)/g,  //[...]: <url>
          ];
          var result = [];
          expressions.forEach(expression => {
            var match = expression.exec(content);
            while(match != null) {
              result.push(match[1]);
              match = expression.exec(content);
            }
          });
          return result; // Return array of link. 
      }
    },
    your_target: {
      src: [ "doc/**/*.md", "!doc/layout/*.md" ]         // glob pattern. files path that include links to checking.
      filter: [...] // It has high priority then `options`.
    },
  },
})
```

### Options

#### options.logToFile
- Type : `boolean`
- Default value : false

If this is true, Test report is printed to the file. Default file name to watch is 'deadlink.log'.
It will locate in same directory with Gruntfile.js. If you change file path or name, look at `options.logFilename`

> Note that to enable logging, grunt should be run in verbose mode.

#### options.logAll
- Type : `boolean`
- Default value : false

If this is true, non-broken link is logged. It can used with `options.logToFile`

#### options.logFilename
- Type : `String`
- Default value : 'deadlink.log'

If this is true, non-broken link is logged. It can used with `options.logToFile`

#### options.filter
- Type : `Function` or `Array of RegExp object`
- Default value : regular expression for markdown link form

regular expression to recognize a link. default is markdown.

If this is function, it get a **content** as argument and return **array of link**. So you should extract **links** in **contnet** within filter funciton.

If this is array of RegExp, first submatch string must be *link* to test. For example, markdown can match with `/\[[^\]]*\]\((http[s]?:\/\/[^\) ]+)/g`. To take all html link, regular expression may this form - `/(http[s]?:\/\/[^ ]+)/g`, not this - `/http[s]?:\/\/[^ ]+/g`

#### target.src
- `Required`
- Type : `String` or `Array`

[Glob pattern](https://github.com/isaacs/node-glob#usage) to indicate files that include links for testing it is dead or not.

#### target.filter
- Type : `Function` or `Array of RegExp object`
- Default value : options.filter

Check out `options.filter`. It has high priority then options.


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

