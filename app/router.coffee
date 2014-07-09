`import Ember from 'ember'`

Router = Ember.Router.extend
  location: SignSpinnersENV.locationType

Router.map ->
  this.resource 'business', { path: '/business/:business_id' }
  this.resource 'spinner', { path: '/spinner/:spinner_id' }

`export default Router`
