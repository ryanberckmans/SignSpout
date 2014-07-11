`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  actions:
    signupForSpinnerShift: (spinnerShift) ->
      spinner = this.get 'controllers.spinner.model'
      # WARNING WARNING
      # spinnerShift.setSpinner must occur BEFORE spinner.addSpinnerShift, or else setSpinner will fail silently and not update the SpinnerShift model
      # Ie, the belongsTo side must be set before the hasMany side.
      spinnerShift.setSpinner spinner
      # spinner.addSpinnerShift must occur AFTER spinnerShift.setSpinner
      spinner.addSpinnerShift spinnerShift
      null

`export default controller`
