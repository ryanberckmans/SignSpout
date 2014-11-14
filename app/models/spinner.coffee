`import DS from 'ember-data'`
`import { SHIFT_CAN_MATCH_DEADLINE_MINUTES } from '../mixins/spinner-shift-sorter'`

Spinner = DS.Model.extend
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'
  phone: DS.attr 'string'

  # canWorkShift returns a promise that resolves to true if this Spinner is eligible to work the passed SpinnerShift.
  # Eventually, ineligiblity may arise from any number of sources - one shift per day, no more than X hours per week, this guy can't work Tuesdays, spinner blacklisted by a company, etc.
  # @return {Promise} resolves true if this Spinner can work the passed SpinnerShift
  canWorkShift: (spinnerShift) ->
    newShiftDayOfYear = moment(spinnerShift.get 'startDateAndTime').dayOfYear()
    @get('spinnerShifts').then (existingShifts) ->
      notYetWorkingThatDay = ->
        alreadyWorkingThatDay = false
        existingShifts.forEach (existingShift) ->
          alreadyWorkingThatDay ||= newShiftDayOfYear == moment(existingShift.get 'startDateAndTime').dayOfYear()      
        !alreadyWorkingThatDay

      # An unmatched shift cannot be matched if its start time is sooner than SHIFT_CAN_MATCH_DEADLINE_MINUTES
      shiftAvailable = ->
        moment().isBefore(moment(spinnerShift.get('startDateAndTime')).subtract(SHIFT_CAN_MATCH_DEADLINE_MINUTES, 'minutes'))

      notYetWorkingThatDay() && shiftAvailable()

`export default Spinner`
