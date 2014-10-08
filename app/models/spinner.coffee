`import DS from 'ember-data'`

Spinner = DS.Model.extend
  # WARNING: As of emberfire 1.2.6, this order of events must occur for the association to persist:
  #          Association must be locally and bidirectionally wired before any save(),
  #          then belongsTo.save() must occur before hasMany.save():
  #            1. (existing spinner, existing spinnerShift)
  #            2. spinnerShift set to spinner, no save()
  #            3. add spinnerShift to spinner.spinnerShifts, no save()
  #            4. spinnerShift.save()
  #            5. spinner.save()
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'

  # canWorkShift returns a promise that resolves to true if this Spinner is eligible to work the passed SpinnerShift. 
  # Eventually, ineligiblity may arise from any number of sources - one shift per day, no more than X hours per week, this guy can't work Tuesdays, spinner blacklisted by a company, etc.
  # Currently, only prohibit spinners from working more than one shift per day
  # @return {Promise} resolves true if this Spinner can work the passed SpinnerShift
  canWorkShift: (spinnerShift) ->
    newShiftDayOfYear = moment(spinnerShift.get 'startDateAndTime').dayOfYear()
    @get('spinnerShifts').then (existingShifts) ->
      alreadyWorkingThatDay = false
      existingShifts.forEach (existingShift) ->
        alreadyWorkingThatDay ||= newShiftDayOfYear == moment(existingShift.get 'startDateAndTime').dayOfYear()      
      !alreadyWorkingThatDay

  # Add a SpinnerShift to this Spinner.
  #
  # @param spinnerShift {SpinnerShift} - new SpinnerShift to add to this Spinner
  #   WARNING - spinnerShift should already be set to this spinner, but not yet saved()  
  #
  # WARNING: As of emberfire 1.2.6, this order of events must occur for the association to persist:
  #          Association must be locally and bidirectionally wired before any save(),
  #          then belongsTo.save() must occur before hasMany.save():
  #            1. (existing spinner, existing spinnerShift)
  #            2. spinnerShift set to spinner, no save()
  #            3. add spinnerShift to spinner.spinnerShifts, no save()
  #            4. spinnerShift.save()
  #            5. spinner.save()
  #
  # @return {Promise} Returns a promise that resolves when the passed spinnerShift has been added to this spinner, however the spinner hasn't been save()
  addSpinnerShift: (spinnerShift) ->
    _this = this
    @get('spinnerShifts').then (spinnerShifts) ->
      spinnerShifts.addObject spinnerShift
      Ember.Logger.debug 'Spinner.addSpinnerShift, added spinnerShift ' + spinnerShift.get('id') + ' to spinner ' + _this.get('id') + '. Has not been save()'

  # Save this Spinner and rollback if the save fails.
  # Rolling back ensures local and remote data are syncd
  rollbackUnlessSave: ->
    _this = this
    @save().catch (reason) ->
          Ember.Logger.error "Spinner " + _this.get('id') + " save() failed. Rolling back. Reason " + reason
          _this.rollback()
          throw reason

`export default Spinner`
