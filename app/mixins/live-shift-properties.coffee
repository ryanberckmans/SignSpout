`import Ember from 'ember'`

# Requires ClockMixin
LiveShiftPropertiesMixin = Ember.Mixin.create

  actions:
    startBreak: ->
      Ember.Logger.debug 'starting startBreak'

      spinnerShift = @get 'model'
      now = Date()
      spinnerShift.set 'breakStartDateAndTime', moment(now).add(30, 'seconds').startOf('minute').toDate() # Round to the nearest minute
      spinnerShift.set 'breakEndDateAndTime', moment(now).add(@get('breakLengthMinutes'), 'minutes').toDate()

      onSaveSuccess = ->
        Ember.Logger.debug 'saved spinnerShift ' + spinnerShift.get('id') + '. breakStartDateAndTime: ' + spinnerShift.get('breakStartDateAndTime') + '. breakEndDateAndTime: ' + spinnerShift.get('breakEndDateAndTime')

      onSaveFail = (reason) ->
        Ember.Logger.error 'failed to save spinnerShift ' + spinnerShift.get('id') + '. Rolling back spinnerShift. breakStartDateAndTime: ' + spinnerShift.get('breakStartDateAndTime') + '. breakEndDateAndTime: ' + spinnerShift.get('breakEndDateAndTime')
        spinnerShift.rollback()

      spinnerShift.save().then onSaveSuccess, onSaveFail

    startLunch: ->
      Ember.Logger.debug 'starting startLunch'

      spinnerShift = @get 'model'
      now = Date()
      spinnerShift.set 'lunchStartDateAndTime', moment(now).add(30, 'seconds').startOf('minute').toDate() # Round to the nearest minute
      spinnerShift.set 'lunchEndDateAndTime', moment(now).add(@get('lunchLengthMinutes'), 'minutes').toDate()

      onSaveSuccess = ->
        Ember.Logger.debug 'saved spinnerShift ' + spinnerShift.get('id') + '. lunchStartDateAndTime: ' + spinnerShift.get('lunchStartDateAndTime') + '. lunchEndDateAndTime: ' + spinnerShift.get('lunchEndDateAndTime')

      onSaveFail = (reason) ->
        Ember.Logger.error 'failed to save spinnerShift ' + spinnerShift.get('id') + '. Rolling back spinnerShift. lunchStartDateAndTime: ' + spinnerShift.get('lunchStartDateAndTime') + '. lunchEndDateAndTime: ' + spinnerShift.get('lunchEndDateAndTime')
        spinnerShift.rollback()

      spinnerShift.save().then onSaveSuccess, onSaveFail

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
  ).property 'startDateAndTime', 'eachSecond'

  # Break Properties

  tooEarlyForBreak: (->
    @get('shiftMinutesElapsed') < @get('minimumMinutesBeforeCanTakeBreak')
  ).property 'shiftMinutesElapsed', 'minimumMinutesBeforeCanTakeBreak'

  canTakeBreak: (->
    !@get('onLunch') && !@get('tooEarlyForBreak') && !@get('breakStartDateAndTime')
  ).property 'tooEarlyForBreak', 'breakStartDateAndTime', 'onLunch'

  onBreak: (->
    @get('breakEndDateAndTime')? && moment(Date()).diff(@get('breakEndDateAndTime')) < 0
  ).property 'eachSecond', 'breakEndDateAndTime'

  breakDone: (->
    @get('breakEndDateAndTime')? && moment(Date()).diff(@get('breakEndDateAndTime')) > 0
  ).property 'eachSecond', 'breakEndDateAndTime'

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

  canTakeLunch: (->
    !@get('onBreak') && !@get('tooEarlyForLunch') && !@get('lunchStartDateAndTime')
  ).property 'tooEarlyForLunch', 'lunchStartDateAndTime', 'onBreak'

  onLunch: (->
    @get('lunchEndDateAndTime')? && moment(Date()).diff(@get('lunchEndDateAndTime')) < 0
  ).property 'eachSecond', 'lunchEndDateAndTime'

  lunchDone: (->
    @get('lunchEndDateAndTime')? && moment(Date()).diff(@get('lunchEndDateAndTime')) > 0
  ).property 'eachSecond', 'lunchEndDateAndTime'

  lunchEndDateAndTimeDisplay: (->
    moment(@get 'lunchEndDateAndTime').format 'h:mma'
  ).property 'lunchEndDateAndTime'

`export default LiveShiftPropertiesMixin`
