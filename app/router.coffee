`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  this.resource 'business', { path: '/business/:business_id' }, ->
    this.route 'book-spinner'
  this.resource 'spinner', { path: '/spinner/:spinner_id' }, ->
    this.route 'shift-signup'

`export default Router`
