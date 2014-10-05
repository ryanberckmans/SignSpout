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


  # Time-dependent partition of matchedShifts
  #
  # liveShifts - happening now
  # postLiveShifts - over and not yet completed
  # nearFutureShifts - shifts which are happening today, or within nearFutureThresholdMinutes
  # upcomingShifts - all other matched shifts, ie shifts too far in future to be included in nearFutureShifts

  nearFutureThresholdMinutes: 60*24

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

  nearFutureShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes')) && now.isBefore(moment(spinnerShift.get 'startDateAndTime'))
  ).property 'matchedShifts.@each', 'clock.eachSecond'

  upcomingShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('matchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes'))
  ).property 'matchedShifts.@each', 'clock.eachSecond'

`export default SpinnerShiftSorterMixin`
