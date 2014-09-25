`import DS from 'ember-data'`

Spinner = DS.Model.extend
  # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
  # Ie, SpinnerShift.belongsTo Spinner must be set BEFORE Spinner.hasMany SpinnerShift.
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'

  # canWorkShift returns a promise that resolves to true if this Spinner is eligible to work the passed SpinnerShift. 
  # Eventually, ineligiblity may arise from any number of sources - one shift per day, no more than X hours per week, this guy can't work Tuesdays, spinner blacklisted by a company, etc.
  # Currently, only prohibit spinners from working more than one shift per day
  canWorkShift: (spinnerShift) ->
    newShiftDayOfYear = moment(spinnerShift.get 'startDateAndTime').dayOfYear()
    @get('spinnerShifts').then (existingShifts) ->
      alreadyWorkingThatDay = false
      existingShifts.forEach (existingShift) ->
        alreadyWorkingThatDay ||= newShiftDayOfYear == moment(existingShift.get 'startDateAndTime').dayOfYear()      
      !alreadyWorkingThatDay

  # Add a SpinnerShift to this Spinner. Mutate and save only this Spinner; the SpinnerShift is updated elsewhere.
  addSpinnerShift: (spinnerShift) ->
    _spinner = this
    @get('spinnerShifts').then (spinnerShifts) ->
        spinnerShifts.addObject spinnerShift
        _spinner.save()

`export default Spinner`
