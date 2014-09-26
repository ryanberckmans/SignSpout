`import Ember from 'ember'`

BusinessIndexController = Ember.ObjectController.extend
  needs: 'business'

  actions:
    setShiftSpinnerRating: (context) ->
      context.spinnerShift.setSpinnerRating context.spinnerRating
      null

`export default BusinessIndexController`
