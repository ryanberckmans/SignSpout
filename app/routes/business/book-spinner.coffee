`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    business = @modelFor 'business'
    @store.createRecord 'spinner-shift', { business: business, startDateAndTime: null }

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set 'selectedDateAsMoment', controller.get('bookingDatesAsMoments')[0]
    controller.set 'selectedStartTimeOfDayAsMoment', controller.get('shiftStartTimesOfDayAsMoments')[8] # Ugly, ie [8] happens to be 11am which is a nice start time
    
    controller.selectedStartDateAndTimeChanged()    # This observer isn't automatically called at this point; call it ourselves to ensure the model is synchronized with the default selections
    controller.shiftEndTimesOfDayAsMomentsChanged() # This observer isn't automatically called at this point; call it ourselves to ensure the model is synchronized with the default selections
    controller.selectedEndDateAndTimeChanged()      # This observer isn't automatically called at this point; call it ourselves to ensure the model is synchronized with the default selections

`export default route`
