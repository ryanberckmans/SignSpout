`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  needs: 'spinner'

  #actions:
  #  signupForSpinnerShift: (spinner, spinnerShift) ->
  #    # TODO - this action should be in BusinessRoute, where the business object is in scope.
  #    spinner = null #
  #    spinner.addSpinnerShift spinnerShift
  #    spinnerShift.setSpinner spinner
  #    this.transitionToRoute 'spinner', spinner
  #    null

#  availableShifts: 

`export default controller`
