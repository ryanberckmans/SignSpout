`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  actions:
    signupForSpinnerShift: (spinnerShift) ->
      spinner = @get 'controllers.spinner.model'
      # WARNING WARNING
      # spinnerShift.setSpinner must occur BEFORE spinner.addSpinnerShift, or else setSpinner will fail silently and not update the SpinnerShift model
      # Ie, the belongsTo side must be set before the hasMany side.
      return unless spinnerShift.setSpinner spinner # setSpinner() returns true if the spinner was successfully set
      # spinner.addSpinnerShift must occur AFTER spinnerShift.setSpinner
      spinner.addSpinnerShift spinnerShift
      null

  availableShifts: []

  # This observer is a work-around to Store.filter not accepting Promises. See https://github.com/emberjs/data/issues/1865
  computeAvailableShifts: (->
    _this = this
    spinner = @get 'controllers.spinner.model'
    Ember.RSVP.filter(@get('model').toArray(), (spinnerShift) -> spinner.canWorkShift spinnerShift).then (availableShifts) ->
      _this.set 'availableShifts', availableShifts
  ).observes('model.@each', 'controllers.spinner.model.spinnerShifts.@each').on('init')

`export default controller`
