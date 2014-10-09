`import Ember from 'ember'`

SHIFT_CAN_MATCH_DEADLINE_MINUTES = 180

# Requires Clock
SpinnerShiftSorterMixin = Ember.Mixin.create

  # Configuration
  shiftCanMatchDeadlineMinutes: SHIFT_CAN_MATCH_DEADLINE_MINUTES # unmatchedShifts whose start time is sooner than shiftCanMatchDeadlineMinutes are partitioned as noMatchFoundShifts
  nearFutureThresholdMinutes: 60*24 # matchedShifts whose start time is sooner than nearFutureThresholdMinutes (without actually having started) are partitioned as nearFutureShifts

  # Private.
  _sortedSpinnerShifts: (->
    spinnerShifts = @get 'spinnerShifts'
    nowMillis = moment().valueOf()
    Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
      sortProperties: ['startDateAndTime']
      # sortFunction compares each shift's closeness to now.
      # This provides desired behavior when _sortedSpinnerShifts is later partitioned:
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

  # Private. _unmatchedShifts is partitioned into availableShifts and noMatchFoundShifts
  _unmatchedShifts: (->
    @get('_sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.unmatched()
  ).property '_sortedSpinnerShifts'

  # Private. _matchedShifts is partitioned into liveShifts, postLiveShifts, nearFutureShifts and upcomingShifts
  _matchedShifts: (->
    @get('_sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.matched()
  ).property '_sortedSpinnerShifts'

  completedShifts: (->
    @get('_sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.completed()
  ).property '_sortedSpinnerShifts'

  cancelledShifts: (->
    @get('_sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.cancelled()
  ).property '_sortedSpinnerShifts'

  erroredShifts: (->
    @get('_sortedSpinnerShifts').filter (spinnerShift) ->
        spinnerShift.errored()
  ).property '_sortedSpinnerShifts'

  # Time-dependent partition of _unmatchedShifts
  #
  # availableShifts    - unmatched shifts waiting for a Spinner
  # noMatchFoundShifts - unmatched shifts whose start time is sooner than shiftCanMatchDeadlineMinutes

  availableShifts: (->
    now = moment()
    shiftCanMatchDeadlineMinutes = @get 'shiftCanMatchDeadlineMinutes'
    @get('_unmatchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get('startDateAndTime')).subtract(shiftCanMatchDeadlineMinutes, 'minutes'))      
  ).property '_unmatchedShifts', 'clock.eachSecond'

  noMatchFoundShifts: (->
    now = moment()
    shiftCanMatchDeadlineMinutes = @get 'shiftCanMatchDeadlineMinutes'
    @get('_unmatchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get('startDateAndTime')).subtract(shiftCanMatchDeadlineMinutes, 'minutes'))      
  ).property '_unmatchedShifts', 'clock.eachSecond'

  # Time-dependent partition of _matchedShifts
  #
  # liveShifts - happening now
  # postLiveShifts - over and not yet completed
  # nearFutureShifts - shifts which are happening today, or within nearFutureThresholdMinutes
  # upcomingShifts - all other matched shifts, ie shifts too far in future to be included in nearFutureShifts

  liveShifts: (->
    now = moment()
    @get('_matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime')) && now.isBefore(moment(spinnerShift.get 'endDateAndTime'))
  ).property '_matchedShifts', 'clock.eachSecond'

  postLiveShifts: (->
    now = moment()
    @get('_matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'endDateAndTime'))
  ).property '_matchedShifts', 'clock.eachSecond'

  nearFutureShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('_matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes')) && now.isBefore(moment(spinnerShift.get 'startDateAndTime'))
  ).property '_matchedShifts', 'clock.eachSecond'

  upcomingShifts: (->
    now = moment()
    nearFutureThresholdMinutes = @get('nearFutureThresholdMinutes')
    @get('_matchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get 'startDateAndTime').subtract(nearFutureThresholdMinutes, 'minutes'))
  ).property '_matchedShifts', 'clock.eachSecond'

`export default SpinnerShiftSorterMixin`

# This constant is used in models/Spinner.canWorkShift, to prevent a spinner from signing up for a shift in noMatchFoundShifts
#
# Why export SHIFT_CAN_MATCH_DEADLINE_MINUTES? I considered two options:
#  1. declare the constant in SpinnerShiftSorter and use export
#  2. declare the constant in config/environment.js, and import config into SpinnerShiftSorter and Spinner.
#
# I chose to go with (1.) because this App has a convention of placing configurable busines logic constants in the module owning that business logic. I don't store any business logic in config/environment.js, and I didn't want to start now.
`export { SHIFT_CAN_MATCH_DEADLINE_MINUTES }`
