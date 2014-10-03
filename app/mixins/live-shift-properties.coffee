`import Ember from 'ember'`

# Requires Clock
LiveShiftPropertiesMixin = Ember.Mixin.create
  ## Configurable Properties

  breakMinutesPerHour: 3,   # every shift recieives 3 break minutes per hour
  lunchLengthMinutes: 30, # lunch is always a flat 30 minutes
  minimumShiftLengthForLunchMinutes: 209, # ie just under 3.5 hours
  minimumMinutesBeforeCanTakeBreak: 60, # ie must complete first hour of shift before going on break
  minimumMinutesBeforeCanTakeLunch: 120, # ie must complete first two hours of shfit before going on lunch

  ## Computed Properties
  startDateAndTimeDisplay: (->
    moment(@get 'startDateAndTime').format 'h:mma'
  ).property 'startDateAndTime'

  endDateAndTimeDisplay: (->
    moment(@get 'endDateAndTime').format 'h:mma'
  ).property 'endDateAndTime'

  shiftLengthMinutes: (->
    moment(@get('endDateAndTime')).diff(@get('startDateAndTime'), 'minutes')
  ).property 'startDateAndTime', 'endDateAndTime'

  shiftMinutesElapsed: (->
    shiftMinutesElapsed = moment(Date()).diff(@get('startDateAndTime'), 'minutes')
    Ember.Logger.debug "shift minutes elapsed: " + shiftMinutesElapsed
    shiftMinutesElapsed
  ).property 'startDateAndTime', 'clock.eachSecond'

  # Break Properties

  tooEarlyForBreak: (->
    @get('shiftMinutesElapsed') < @get('minimumMinutesBeforeCanTakeBreak')
  ).property 'shiftMinutesElapsed', 'minimumMinutesBeforeCanTakeBreak'

  onLunchAndBreakDisabled: (->
    @get('onLunch') && !@get('tooEarlyForBreak') && !@get('breakStartDateAndTime')
  ).property 'tooEarlyForBreak', 'breakStartDateAndTime', 'onLunch'

  canTakeBreak: (->
    !@get('onLunch') && !@get('tooEarlyForBreak') && !@get('breakStartDateAndTime')
  ).property 'tooEarlyForBreak', 'breakStartDateAndTime', 'onLunch'

  onBreak: (->
    @get('breakEndDateAndTime')? && moment(Date()).diff(@get('breakEndDateAndTime')) < 0
  ).property 'clock.eachSecond', 'breakEndDateAndTime'

  breakDone: (->
    @get('breakEndDateAndTime')? && moment(Date()).diff(@get('breakEndDateAndTime')) > 0
  ).property 'clock.eachSecond', 'breakEndDateAndTime'

  breakLengthMinutes: (->
    Math.round(@get('breakMinutesPerHour') * @get('shiftLengthMinutes') / 60)
  ).property 'shiftLengthMinutes', 'breakMinutesPerHour'

  breakEndDateAndTimeDisplay: (->
    moment(@get 'breakEndDateAndTime').format 'h:mma'
  ).property 'breakEndDateAndTime'

  # Lunch Properties

  shiftHasLunch: (->
    @get('shiftLengthMinutes') > @get('minimumShiftLengthForLunchMinutes')
  ).property 'minimumShiftLengthForLunchMinutes', 'shiftLengthMinutes'

  tooEarlyForLunch: (->
    @get('shiftMinutesElapsed') < @get('minimumMinutesBeforeCanTakeLunch')
  ).property 'shiftMinutesElapsed', 'minimumMinutesBeforeCanTakeLunch'

  onBreakAndLunchDisabled: (->
    @get('onBreak') && !@get('tooEarlyForLunch') && !@get('lunchStartDateAndTime')
  ).property 'tooEarlyForLunch', 'lunchStartDateAndTime', 'onBreak'

  canTakeLunch: (->
    !@get('onBreak') && !@get('tooEarlyForLunch') && !@get('lunchStartDateAndTime')
  ).property 'tooEarlyForLunch', 'lunchStartDateAndTime', 'onBreak'

  onLunch: (->
    @get('lunchEndDateAndTime')? && moment(Date()).diff(@get('lunchEndDateAndTime')) < 0
  ).property 'clock.eachSecond', 'lunchEndDateAndTime'

  lunchDone: (->
    @get('lunchEndDateAndTime')? && moment(Date()).diff(@get('lunchEndDateAndTime')) > 0
  ).property 'clock.eachSecond', 'lunchEndDateAndTime'

  lunchEndDateAndTimeDisplay: (->
    moment(@get 'lunchEndDateAndTime').format 'h:mma'
  ).property 'lunchEndDateAndTime'

`export default LiveShiftPropertiesMixin`
