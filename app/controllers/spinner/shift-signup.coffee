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
        Ember.Logger.error "shift-signup: spinner " + spinner.id + " failed to add spinnerShift " + spinnerShift.id + ". The spinner was already set on the spinnerShift, and we're now inconsistent. This error cannot be recovered from right now, since SpinnerShift has no api to delete a matched spinner and revert to unmatched. What I really need here is a transaction() on the Spinner and SpinnerShift. Emberfire doesn't support transactions as of 2014/10."
        throw reason

      onSetSpinnerSuccess = ->
        Ember.Logger.info "shift-signup: spinnerShift " + spinnerShift.id + " had spinner set to " + spinner.id
        # spinner.addSpinnerShift must occur AFTER spinnerShift.setSpinner
        spinner.addSpinnerShift(spinnerShift).then onAddSpinnerShiftSuccess, onAddSpinnerShiftFail

      onSetSpinnerFail = (reason) ->
        Ember.Logger.error "shift-signup: spinnerShift " + spinnerShift.id + " failed to set spinner " + spinner.id
        throw reason

      # WARNING WARNING
      # spinnerShift.setSpinner must occur BEFORE spinner.addSpinnerShift, or else setSpinner will fail silently and not update the SpinnerShift model
      # Ie, the belongsTo side must be set before the hasMany side.
      spinnerShift.setSpinner(spinner).then onSetSpinnerSuccess, onSetSpinnerFail

      # TODO TODO TODO
      # TODO TODO TODO - when anything fails, need transition to some kind of error page. Or set an error message.
      # TODO TODO TODO

      null

  areTakeShiftButtonsDisabled: false
  availableShifts: []

  # This observer is a work-around to Store.filter not accepting Promises. See https://github.com/emberjs/data/issues/1865
  computeAvailableShifts: (->
    _this = this
    spinner = @get 'controllers.spinner.model'
    Ember.RSVP.filter(@get('model').toArray(), (spinnerShift) -> spinner.canWorkShift spinnerShift).then (availableShifts) ->
      _this.set 'availableShifts', availableShifts
  ).observes('model.@each', 'controllers.spinner.model.spinnerShifts.@each').on('init')

`export default controller`
