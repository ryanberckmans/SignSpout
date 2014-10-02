`import Ember from 'ember'`

LiveShiftPropertiesMixin = Ember.Mixin.create

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
