`import Ember from 'ember'`

# Requires ClockMixin
LiveShiftPropertiesMixin = Ember.Mixin.create

  ## Configurable Properties

  breakMinutesPerHour: 3,   # every shift recieives 3 break minutes per hour
  lunchDurationMinutes: 30, # lunch is always a flat 30 minutes
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

  tooEarlyForBreak: (->
    shiftMinutesElapsed = moment(Date()).diff(@get 'startDateAndTime', 'minutes')
    Ember.Logger.debug "shift minutes elapsed: " + shiftMinutesElapsed
    shiftMinutesElapsed < @get('minimumMinutesBeforeCanTakeBreak')
  ).property 'eachSecond'

  canTakeBreak: (->
    !@get('tooEarlyForBreak') && !@get('breakStartDateAndTime')
  ).property 'tooEarlyForBreak', 'breakStartDateAndTime'

  onBreak: (->
    @get('breakEndDateAndTime') && moment(Date()).diff(@get('breakEndDateAndTime')) < 0
  ).property 'eachSecond', 'breakEndDateAndTime'

  breakDone: (->
    @get('breakEndDateAndTime') && moment(Date()).diff(@get('breakEndDateAndTime')) > 0
  ).property 'eachSecond', 'breakEndDateAndTime'

  shiftLengthMinutes: (->
    moment(@get('endDateAndTime')).diff(@get 'startDateAndTime', 'minutes')
  ).property 'startDateAndTime', 'endDateAndTime'

  breakLengthMinutes: (->
    Math.round(@get('breakMinutesPerHour') * get('shiftLengthMinutes') / 60)
  ).property 'shiftLengthMinutes', 'breakMinutesPerHour'

  breakEndDateAndTimeDisplay: (->
    moment(@get 'breakEndDateAndTime').format 'h:mma'
  ).property 'breakEndDateAndTime'

  shiftHasLunch: false
  tooEarlyForLunch: null
  canTakeLunch: null
  onLunch: null
  lunchDone: null
  lunchLengthMinutes: null
  lunchEndDateAndTimeDisplay: null

`export default LiveShiftPropertiesMixin`
