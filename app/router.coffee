`import Ember from 'ember'`

Router = Ember.Router.extend
  location: SignSpinnersENV.locationType

Router.map ->
  this.resource 'business', { path: '/business/:business_id' }, ->
    this.route 'book-spinner'
  this.resource 'spinner', { path: '/spinner/:spinner_id' }, ->
    this.route 'shift-signup'

`export default Router`
