`import Ember from 'ember'`

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

  tooEarlyForBreak: null
  canTakeBreak: null
  onBreak: null
  breakDone: null
  breakLengthMinutes: null
  breakEndDateAndTimeDisplay: null

  shiftHasLunch: null
  tooEarlyForLunch: null
  canTakeLunch: null
  onLunch: null
  lunchDone: null
  lunchLengthMinutes: null
  lunchEndDateAndTimeDisplay: null

`export default LiveShiftPropertiesMixin`
