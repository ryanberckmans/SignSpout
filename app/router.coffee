`import Ember from 'ember'`

Router = Ember.Router.extend
  location: SignSpinnersENV.locationType

Router.map ->
  this.resource 'business', { path: '/:business_id' }

`export default Router`
