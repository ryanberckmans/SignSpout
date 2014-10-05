`import Ember from 'ember'`

SpinnerProfileRoute = Ember.Route.extend
  model: ->
    this.modelFor 'spinner'

`export default SpinnerProfileRoute`
