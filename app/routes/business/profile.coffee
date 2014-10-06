`import Ember from 'ember'`

BusinessProfileRoute = Ember.Route.extend
  model: ->
    this.modelFor 'business'

`export default BusinessProfileRoute`
