`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    business = @modelFor 'business'
    @store.createRecord 'spinner-shift', { business: business, startDateAndTime: new Date() }

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.send 'setSpinnerShiftDate', controller.get('soonestBookingDateAsMoment')

`export default route`
