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
  shiftLengthMinutes: (->
    moment(@get('endDateAndTime')).diff(@get('startDateAndTime'), 'minutes')
  ).property 'startDateAndTime', 'endDateAndTime'

  shiftMinutesElapsed: (->
    moment().diff(@get('startDateAndTime'), 'minutes')
  ).property 'startDateAndTime', 'clock.eachSecond'

  # Break Properties

  tooEarlyForBreak: (->
    @get('shiftMinutesElapsed') < @get('minimumMinutesBeforeCanTakeBreak')
  ).property 'shiftMinutesElapsed', 'minimumMinutesBeforeCanTakeBreak'

  canTakeBreak: (->
    !@get('onLunch') && !@get('tooEarlyForBreak') && !@get('breakStartDateAndTime')
  ).property 'tooEarlyForBreak', 'breakStartDateAndTime', 'onLunch'

  onBreak: (->
    @get('breakEndDateAndTime')? && moment().diff(@get('breakEndDateAndTime')) < 0
  ).property 'clock.eachSecond', 'breakEndDateAndTime'

  breakDone: (->
    @get('breakEndDateAndTime')? && moment().diff(@get('breakEndDateAndTime')) > 0
  ).property 'clock.eachSecond', 'breakEndDateAndTime'

  breakLengthMinutes: (->
    Math.round(@get('breakMinutesPerHour') * @get('shiftLengthMinutes') / 60)
  ).property 'shiftLengthMinutes', 'breakMinutesPerHour'

  # Lunch Properties

  shiftHasLunch: (->
    @get('shiftLengthMinutes') > @get('minimumShiftLengthForLunchMinutes')
  ).property 'minimumShiftLengthForLunchMinutes', 'shiftLengthMinutes'

  tooEarlyForLunch: (->
    @get('shiftMinutesElapsed') < @get('minimumMinutesBeforeCanTakeLunch')
  ).property 'shiftMinutesElapsed', 'minimumMinutesBeforeCanTakeLunch'

  lunchDisabledUntilBreakDone: (->
    !@get('breakDone') && !@get('tooEarlyForLunch') && !@get('lunchStartDateAndTime')
  ).property 'tooEarlyForLunch', 'lunchStartDateAndTime', 'onBreak'

  canTakeLunch: (->
    @get('breakDone') && !@get('tooEarlyForLunch') && !@get('lunchStartDateAndTime')
  ).property 'tooEarlyForLunch', 'lunchStartDateAndTime', 'onBreak'

  onLunch: (->
    @get('lunchEndDateAndTime')? && moment().diff(@get('lunchEndDateAndTime')) < 0
  ).property 'clock.eachSecond', 'lunchEndDateAndTime'

  lunchDone: (->
    @get('lunchEndDateAndTime')? && moment().diff(@get('lunchEndDateAndTime')) > 0
  ).property 'clock.eachSecond', 'lunchEndDateAndTime'

`export default LiveShiftPropertiesMixin`
