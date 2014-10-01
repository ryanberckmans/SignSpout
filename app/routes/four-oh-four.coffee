`import Ember from 'ember'`

FourOhFourRoute = Ember.Route.extend
  beforeModel: ->
    Ember.Logger.info 'route FourOhFour transitioning to index'
    @transitionTo 'index'

`export default FourOhFourRoute`
