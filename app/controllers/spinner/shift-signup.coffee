`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  actions:
    signupForSpinnerShift: (spinnerShift) ->
      _this = this
      @set 'areTakeShiftButtonsDisabled', true
      spinner = @get 'controllers.spinner.model'

      onAddSpinnerShiftSuccess = ->
        Ember.Logger.info "shift-signup: spinner " + spinner.id + " added spinnerShift " + spinnerShift.id
        _this.set 'areTakeShiftButtonsDisabled', false

      onAddSpinnerShiftFail = (reason) ->
        Ember.Logger.error "shift-signup: spinner " + spinner.id + " failed to add spinnerShift " + spinnerShift.id + ". The spinner was already set on the spinnerShift, and we're now inconsistent. This error cannot be recovered from right now, since SpinnerShift has no api to delete a matched spinner and revert to unmatched. What I really need here is a transaction() on the Spinner and SpinnerShift. Emberfire doesn't support transactions as of 2014/10. This error isn't rethrown and is trapped here. Reason: " + reason
        _this.set 'areTakeShiftButtonsDisabled', false

      onSetSpinnerSuccess = ->
        Ember.Logger.info "shift-signup: spinnerShift " + spinnerShift.id + " had spinner set to " + spinner.id
        # spinner.addSpinnerShift must occur AFTER spinnerShift.setSpinner
        spinner.rollbackUnlessSave().then onAddSpinnerShiftSuccess, onAddSpinnerShiftFail

      onSetSpinnerFail = (reason) ->
        spinner.rollback()
        Ember.Logger.error "shift-signup: spinnerShift " + spinnerShift.id + " failed to set spinner " + spinner.id + ". Spinner has been rolled back. This error isn't rethrown and is trapped here. Reason: " + reason
        _this.set 'areTakeShiftButtonsDisabled', false

      # WARNING: As of emberfire 1.2.6, this order of events must occur for the association to persist:
      #          Association must be locally and bidirectionally wired before any save(),
      #          then belongsTo.save() must occur before hasMany.save():
      #            1. (existing spinner, existing spinnerShift)
      #            2. spinnerShift set to spinner, no save()
      #            3. add spinnerShift to spinner.spinnerShifts, no save()
      #            4. spinnerShift.save()
      #            5. spinner.save()
      spinner.addSpinnerShift(spinnerShift).then ->
        spinnerShift.setSpinner(spinner).then onSetSpinnerSuccess, onSetSpinnerFail

      null

  areTakeShiftButtonsDisabled: false
  availableShifts: []

  # This observer is a work-around to Store.filter not accepting Promises. See https://github.com/emberjs/data/issues/1865
  computeAvailableShifts: (->
    _this = this
    spinner = @get 'controllers.spinner.model'
    Ember.RSVP.filter(@get('model').toArray(), (spinnerShift) -> spinner.canWorkShift spinnerShift).then (availableShifts) ->
      sortedAvailableShifts = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
        sortProperties: ['startDateAndTime']
        sortFunction: (startDateAndTime1, startDateAndTime2) ->
          millis1 = moment(startDateAndTime1).valueOf()
          millis2 = moment(startDateAndTime2).valueOf()
          return 0 if millis1 == millis2
          return -1 if millis1 < millis2
          return 1
        content: availableShifts
        sortAscending: true
      _this.set 'availableShifts', sortedAvailableShifts

  ).observes('model.@each', 'controllers.spinner.model.spinnerShifts.@each').on('init')

`export default controller`
