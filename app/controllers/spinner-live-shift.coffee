`import Ember from 'ember'`
`import LiveShiftPropertiesMixin from '../mixins/live-shift-properties'`

SpinnerLiveShiftController = Ember.ObjectController.extend LiveShiftPropertiesMixin,
  actions:
    startBreak: ->
      Ember.Logger.debug 'starting startBreak'

      spinnerShift = @get 'model'
      now = moment()
      spinnerShift.set 'breakStartDateAndTime', now.clone().add(30, 'seconds').startOf('minute').toDate() # Round to the nearest minute
      spinnerShift.set 'breakEndDateAndTime', now.clone().add(@get('breakLengthMinutes'), 'minutes').add(30, 'seconds').startOf('minute').toDate() # Round to nearest minute

      onSaveSuccess = ->
        Ember.Logger.debug 'saved spinnerShift ' + spinnerShift.get('id') + '. breakStartDateAndTime: ' + spinnerShift.get('breakStartDateAndTime') + '. breakEndDateAndTime: ' + spinnerShift.get('breakEndDateAndTime')

      onSaveFail = (reason) ->
        Ember.Logger.error 'failed to save spinnerShift ' + spinnerShift.get('id') + '. Rolling back spinnerShift. breakStartDateAndTime: ' + spinnerShift.get('breakStartDateAndTime') + '. breakEndDateAndTime: ' + spinnerShift.get('breakEndDateAndTime')
        spinnerShift.rollback()

      spinnerShift.save().then onSaveSuccess, onSaveFail

    startLunch: ->
      Ember.Logger.debug 'starting startLunch'

      spinnerShift = @get 'model'
      now = moment()
      spinnerShift.set 'lunchStartDateAndTime', now.clone().add(30, 'seconds').startOf('minute').toDate() # Round to the nearest minute
      spinnerShift.set 'lunchEndDateAndTime', now.clone().add(@get('lunchLengthMinutes'), 'minutes').add(30, 'seconds').startOf('minute').toDate() # Round to nearest minute

      onSaveSuccess = ->
        Ember.Logger.debug 'saved spinnerShift ' + spinnerShift.get('id') + '. lunchStartDateAndTime: ' + spinnerShift.get('lunchStartDateAndTime') + '. lunchEndDateAndTime: ' + spinnerShift.get('lunchEndDateAndTime')

      onSaveFail = (reason) ->
        Ember.Logger.error 'failed to save spinnerShift ' + spinnerShift.get('id') + '. Rolling back spinnerShift. lunchStartDateAndTime: ' + spinnerShift.get('lunchStartDateAndTime') + '. lunchEndDateAndTime: ' + spinnerShift.get('lunchEndDateAndTime')
        spinnerShift.rollback()

      spinnerShift.save().then onSaveSuccess, onSaveFail

`export default SpinnerLiveShiftController`
