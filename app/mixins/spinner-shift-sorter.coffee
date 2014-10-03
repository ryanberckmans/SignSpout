`import Ember from 'ember'`

# Requires Clock
SpinnerShiftSorterMixin = Ember.Mixin.create
  unmatchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.unmatched()
  ).property 'spinnerShifts.@each.state'

  matchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.matched()
  ).property 'spinnerShifts.@each.state'

  completedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.completed()
  ).property 'spinnerShifts.@each.state'

  cancelledShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.cancelled()
  ).property 'spinnerShifts.@each.state'

  erroredShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.errored()
  ).property 'spinnerShifts.@each.state'

  upcomingShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get 'startDateAndTime'))
  ).property 'matchedShifts.@each', 'clock.eachSecond'

  liveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime')) && now.isBefore(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts.@each', 'clock.eachSecond'

  postLiveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts.@each', 'clock.eachSecond'

`export default SpinnerShiftSorterMixin`
