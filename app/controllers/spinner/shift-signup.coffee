`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  actions:
    signupForSpinnerShift: (spinnerShift) ->
      _this = this
      @set 'areTakeShiftButtonsDisabled', true
      spinner = @get 'controllers.spinner.model'

      done = ->
        _this.set 'areTakeShiftButtonsDisabled', false

      onSpinnerSaveSuccess = ->
        Ember.Logger.info "shift-signup: spinner " + spinner.id + " added spinnerShift " + spinnerShift.id
        done()

      onSpinnerSaveFail = (reason) ->
        Ember.Logger.error "shift-signup: spinner " + spinner.id + " failed to add spinnerShift " + spinnerShift.id + ". The spinner was already set on the spinnerShift, and we're now inconsistent. This error cannot be recovered from right now, since SpinnerShift has no api to delete a matched spinner and revert to unmatched. This error isn't rethrown and is trapped here. Reason: " + reason
        spinner.rollback()
        done()

      onSetSpinnerSuccess = ->
        Ember.Logger.info "shift-signup: spinnerShift " + spinnerShift.id + " had spinner set to " + spinner.id + ". Saving spinner.."
        spinner.save().then onSpinnerSaveSuccess, onSpinnerSaveFail

      onSetSpinnerFail = (reason) ->
        spinnerShift.rollback()
        spinner.rollback()
        Ember.Logger.error "shift-signup: spinnerShift " + spinnerShift.id + " failed to set spinner " + spinner.id + ". Spinner and spinnerShift have been rolled back. This error isn't rethrown and is trapped here. Reason: " + reason
        done()
      
      spinnerShift.setSpinner(spinner).then onSetSpinnerSuccess, onSetSpinnerFail

      null

  areTakeShiftButtonsDisabled: false
  availableShifts: []

  _availableShiftsUnsorted: []

  sortAvailableShifts: (->
    _availableShiftsUnsorted = @get '_availableShiftsUnsorted'
    sortedAvailableShifts = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      sortProperties: ['startDateAndTime']
      sortFunction: (startDateAndTime1, startDateAndTime2) ->
        millis1 = moment(startDateAndTime1).valueOf()
        millis2 = moment(startDateAndTime2).valueOf()
        return 0 if millis1 == millis2
        return -1 if millis1 < millis2
        return 1
      content: _availableShiftsUnsorted
      sortAscending: true
    @set 'availableShifts', sortedAvailableShifts
  ).observes '_availableShiftsUnsorted'

  # This observer is a work-around to Store.filter not accepting Promises. See https://github.com/emberjs/data/issues/1865
  computeAvailableShifts: (->
    _this = this
    spinner = @get 'controllers.spinner.model'
    Ember.RSVP.filter(@get('model').toArray(), (spinnerShift) -> spinner.canWorkShift spinnerShift).then (availableShifts) ->
      _this.set '_availableShiftsUnsorted', availableShifts
  ).observes('model.@each', 'controllers.spinner.model.spinnerShifts.@each', 'clock.eachSecond').on('init')

`export default controller`
