/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var PickFiles = require('broccoli-static-compiler');
var MergeTrees = require('broccoli-merge-trees');

var app = new EmberApp();

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

app.import('bower_components/fontawesome/css/font-awesome.min.css');
var fontawesomeFonts = PickFiles('bower_components/fontawesome/fonts',{
  srcDir: '/',
  files: ['*'],
  destDir: '/fonts'
});

app.import('bower_components/velocity/velocity.js');

app.import('bower_components/twix/bin/twix.js');

// TODO I'm unsure why this http dependency is downloaded as index.js:
//  "ember-list-view": "http://builds.emberjs.com/list-view/list-view-latest.js",
app.import('bower_components/ember-list-view/index.js');
  
app.import('bower_components/moment/moment.js');

app.import('bower_components/emberui/dist/named-amd/emberui.js', {
  exports: {
    'emberui': ['default']
  }
});
app.import('bower_components/emberui/dist/emberui.css');
app.import('bower_components/emberui/dist/default-theme.css');

module.exports = MergeTrees([app.toTree(), fontawesomeFonts]);
