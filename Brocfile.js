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

app.import('vendor/fontawesome/css/font-awesome.min.css');
var fontawesomeFonts = PickFiles('vendor/fontawesome/fonts',{
  srcDir: '/',
  files: ['*'],
  destDir: '/fonts'
});

app.import('vendor/velocity/jquery.velocity.js');

app.import('vendor/twix/bin/twix.js');

app.import({
  development: 'vendor/ember-list-view/list-view.js',
  production: 'vendor/ember-list-view/list-view.prod.js',
});

app.import('vendor/moment/moment.js');

app.import('vendor/emberui/dist/named-amd/emberui.js', {
  exports: {
    'emberui': ['default']
  }
});
app.import('vendor/emberui/dist/emberui.css');
app.import('vendor/emberui/dist/default-theme.css');

module.exports = MergeTrees([app.toTree(), fontawesomeFonts]);
