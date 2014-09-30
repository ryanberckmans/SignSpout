`import Ember from 'ember'`

BusinessIndexController = Ember.ObjectController.extend
  needs: 'business'

  actions:
    cancelSpinnerShift: (context) ->
      context.spinnerShift.cancel().catch (reason) ->
        Ember.Logger.error "business index: cancel failed. This error isn't rethrown and is trapped here. Reason: " + reason
      null

    setShiftSpinnerRating: (context) ->
      context.spinnerShift.setSpinnerRating(context.spinnerRating).catch (reason) ->
        Ember.Logger.error "busines index: setSpinnerRating failed. This error isn't rethrown and is trapped here. Reason: " + reason
      null

`export default BusinessIndexController`
