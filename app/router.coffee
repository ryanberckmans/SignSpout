`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  this.resource 'business', { path: '/business/:business_id' }, ->
    this.route 'book-spinner'
  this.resource 'spinner', { path: '/spinner/:spinner_id' }, ->
    this.route 'shift-signup'
  this.route 'index', { path: '*path' } # Catch-all, glob route. Any unmatched url will redirect to index. Eventually we'll want to redirect to route 'fourOhFour' -> four-oh-four.hbs
                                        # See https://stackoverflow.com/questions/14548594/how-to-handle-no-route-matched-in-ember-js-and-show-404-page

`export default Router`
