`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    business = @modelFor 'business'
    @store.createRecord 'spinner-shift', { business: business }

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.send 'setSpinnerShiftDate', moment() # TODO this should be a default timeOfDay for the earliest booking date, and it should set endTime too.

`export default route`
