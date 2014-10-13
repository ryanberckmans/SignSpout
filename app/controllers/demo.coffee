`import Ember from 'ember'`

DemoController = Ember.Controller.extend
  
  createDemoShiftsButtonIsDisabled: false

  # Create a mock shift; the passed mockShiftParams are injected into the createRecord constructor
  # The passed mockShiftParams.business has the new mock shifted added to its spinnerShifts
  # The passed mockShiftParams.spinner isn't modified at all
  # NOTHING IS save()'d
  createMockShift: (mockShiftParams) ->
    mockSpinnerShift = @store.createRecord 'spinner-shift', mockShiftParams
    Ember.Logger.debug 'Demo: created mock shift: ' + mockSpinnerShift.get('id') + ', state: ' + mockSpinnerShift.get('state') + ', start: ' + mockSpinnerShift.get('startDateAndTime') + ', end: ' + mockSpinnerShift.get('endDateAndTime')
    mockShiftParams.business.get('spinnerShifts').then (spinnerShifts) ->
      spinnerShifts.addObject mockSpinnerShift
    null
  
  actions:
    # Creates a set of demo shifts, without actually calling save()
    createDemoShifts: ->
      _this = this
      @set 'createDemoShiftsButtonIsDisabled', true
      demoBusiness = @get 'demoBusiness'
      demoSpinner  = @get 'demoSpinner'

      Ember.Logger.debug 'createDemoShifts uses business ' + demoBusiness.get('id') + ', spinner ' + demoSpinner.get('id')

      promises = [
        # Recently ended shift, to show spinner rating
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "matched", startDateAndTime: moment().subtract(5, 'hours').startOf('hour').toDate(), endDateAndTime: moment().subtract(1, 'hours').startOf('hour').toDate(),

        # Completed shift #1 with spinner rating set
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "completed", startDateAndTime: moment().subtract(26, 'hours').startOf('hour').toDate(), endDateAndTime: moment().subtract(22, 'hours').startOf('hour').toDate(), spinnerRating: 5,

        # Completed shift #2 with spinner rating set
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "completed", startDateAndTime: moment().subtract(50, 'hours').startOf('hour').toDate(), endDateAndTime: moment().subtract(45, 'hours').startOf('hour').toDate(), spinnerRating: 4,

        # Shift that starts in 2 minutes
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "matched", startDateAndTime: moment().add(2, 'minutes').startOf('minute').toDate(), endDateAndTime: moment().add(4, 'hours').startOf('hour').toDate(),

        # Shift that started 30 mins ago with Spinner working
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "matched", startDateAndTime: moment().subtract(30, 'minutes').startOf('minute').toDate(), endDateAndTime: moment().add(3, 'hours').startOf('hour').toDate(),

        # Shift that started 90 mins ago with Spinner on break
        @createMockShift business: demoBusiness, spinner: demoSpinner, state: "matched", startDateAndTime: moment().subtract(90, 'minutes').startOf('minute').toDate(), endDateAndTime: moment().add(2, 'hours').startOf('hour').toDate(), breakStartDateAndTime: moment().subtract(3, 'minutes').startOf('minute').toDate(), breakEndDateAndTime: moment().add(3, 'minutes').startOf('minute').toDate()]

      Ember.RSVP.all(promises).then -> 
        _this.set 'createDemoShiftsButtonIsDisabled', false
        _this.transitionToRoute 'business', demoBusiness
      null

`export default DemoController`
