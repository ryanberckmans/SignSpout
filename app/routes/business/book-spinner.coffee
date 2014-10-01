`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    null # No model is needed. The new SpinnerShift is created when "Book Spinner" is clicked, see controllers/book-spinner action createSpinnerShift

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set 'selectedDateAsMoment', controller.get('bookingDatesAsMoments')[0]
    controller.set 'selectedStartTimeOfDayAsMoment', controller.get('shiftStartTimesOfDayAsMoments')[8] # Ugly, ie [8] happens to be 11am which is a nice start time
    
    controller.set 'bookSpinnerButtonIsDisabled', false
    controller.shiftEndTimesOfDayAsMomentsChanged() # This observer isn't automatically called at this point; call it ourselves to ensure the model is synchronized with the default selections

`export default route`
