`import Ember from 'ember'`

BusinessIndexController = Ember.ObjectController.extend
  needs: 'business'

  actions:
    cancelSpinnerShift: (context) ->
      context.spinnerShift.cancel()
      null

    setShiftSpinnerRating: (context) ->
      context.spinnerShift.setSpinnerRating context.spinnerRating
      null

`export default BusinessIndexController`
