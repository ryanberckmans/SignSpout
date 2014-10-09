`import DS from 'ember-data'`
`import { SHIFT_CAN_MATCH_DEADLINE_MINUTES } from '../mixins/spinner-shift-sorter'`

Spinner = DS.Model.extend
  # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
  # Ie, SpinnerShift.belongsTo Spinner must be set BEFORE Spinner.hasMany SpinnerShift.
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'

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

  # Add a SpinnerShift to this Spinner. Mutate and save only this Spinner; the SpinnerShift is updated elsewhere.
  # @return {Promise} resolves when the passed spinnerShift is added to this Spinner
  addSpinnerShift: (spinnerShift) ->
    _spinner = this
    @get('spinnerShifts').then (spinnerShifts) ->
        spinnerShifts.addObject spinnerShift
        _spinner.save().catch (reason) ->
          Ember.Logger.error "Spinner " + _spinner.get('id') + " save() failed on addSpinnerShift with spinnerShift " + spinnerShift.get('id') + " . Rolling back this Spinner. Reason " + reason
          _spinner.rollback()
          throw reason

`export default Spinner`
