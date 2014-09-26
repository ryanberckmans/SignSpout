`import Ember from 'ember'`

BusinessController = Ember.ObjectController.extend
  unmatchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->    
        spinnerShift.unmatched()
  ).property 'spinnerShifts.@each.state'

  matchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->    
        spinnerShift.matched()
  ).property 'spinnerShifts.@each.state'

  cancelledShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->    
        spinnerShift.cancelled()
  ).property 'spinnerShifts.@each.state'

  erroredShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->    
        spinnerShift.errored()
  ).property 'spinnerShifts.@each.state'
  
`export default BusinessController`
