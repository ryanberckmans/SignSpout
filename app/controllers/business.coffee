`import Ember from 'ember'`
`import ClockMixin from '../mixins/clock'`

BusinessController = Ember.ObjectController.extend ClockMixin,

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

  liveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime')) && now.isBefore(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts.@each', 'eachMinute'
  
`export default BusinessController`
