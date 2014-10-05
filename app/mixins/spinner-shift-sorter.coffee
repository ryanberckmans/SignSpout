`import Ember from 'ember'`

# Requires Clock
SpinnerShiftSorterMixin = Ember.Mixin.create
  sortedSpinnerShifts: (->
    spinnerShifts = @get 'spinnerShifts'
    nowMillis = moment().valueOf()
    Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      sortProperties: ['startDateAndTime']
      # sortFunction compares each shift's closeness to now.
      # This provides desired behavior when sortedSpinnerShifts is partitioned:
      #   1. shifts in the past are sorted most recent first
      #   2. shifts in the future are sorted soonest first
      # If we simply sorted by startDateAndTime, we could get (1.) xor (2.)
      sortFunction: (startDateAndTime1, startDateAndTime2) ->
        millis1AwayFromNow = Math.abs(nowMillis - moment(startDateAndTime1).valueOf())
        millis2AwayFromNow = Math.abs(nowMillis - moment(startDateAndTime2).valueOf())
        return 0 if millis1AwayFromNow == millis2AwayFromNow
        return -1 if millis1AwayFromNow < millis2AwayFromNow
        return 1
      content: spinnerShifts
      sortAscending: true
  ).property 'spinnerShifts.@each.state'

  unmatchedShifts: (->
    @get('sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.unmatched()
  ).property 'sortedSpinnerShifts'

  matchedShifts: (->
    @get('sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.matched()
  ).property 'sortedSpinnerShifts'

  completedShifts: (->
    @get('sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.completed()
  ).property 'sortedSpinnerShifts'

  cancelledShifts: (->
    @get('sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.cancelled()
  ).property 'sortedSpinnerShifts'

  erroredShifts: (->
    @get('sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.errored()
  ).property 'sortedSpinnerShifts'


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
  ).property 'matchedShifts', 'clock.eachSecond'

  postLiveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts', 'clock.eachSecond'

  nearFutureShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes')) && now.isBefore(moment(spinnerShift.get 'startDateAndTime'))
  ).property 'matchedShifts', 'clock.eachSecond'

  upcomingShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('matchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes'))
  ).property 'matchedShifts', 'clock.eachSecond'

`export default SpinnerShiftSorterMixin`
