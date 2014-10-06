`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @resource 'business', { path: '/business/:business_id' }, ->
    @route 'book-spinner'
    @route 'history'
    @route 'profile'
  @resource 'spinner', { path: '/spinner/:spinner_id' }, ->
    @route 'shift-signup'
    @route 'history'
    @route 'profile'
  @route 'fourOhFour', { path: '*path' } # Catch-all, glob route. See https://stackoverflow.com/questions/14548594/how-to-handle-no-route-matched-in-ember-js-and-show-404-page

`export default Router`
