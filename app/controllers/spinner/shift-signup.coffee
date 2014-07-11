`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  actions:
    signupForSpinnerShift: (spinnerShift) ->
      spinner = this.get 'controllers.spinner.model'
      spinner.addSpinnerShift spinnerShift
      spinnerShift.setSpinner spinner
      null

`export default controller`
