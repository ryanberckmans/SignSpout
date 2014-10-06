`import Ember from 'ember'`

BusinessRoute = Ember.Route.extend
  actions:
    cancelSpinnerShift: (spinnerShift) ->
      spinnerShift.cancel().catch (reason) ->
        Ember.Logger.error "business index: cancel failed. This error isn't rethrown and is trapped here. Reason: " + reason
      null

    setShiftSpinnerRating: (context) ->
      context.spinnerShift.setSpinnerRating(context.spinnerRating).catch (reason) ->
        Ember.Logger.error "busines index: setSpinnerRating failed. This error isn't rethrown and is trapped here. Reason: " + reason
      null

`export default BusinessRoute`
