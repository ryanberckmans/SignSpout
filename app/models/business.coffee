`import DS from 'ember-data'`

Business = DS.Model.extend  
  # WARNING: As of emberfire 1.2.6, this order of events must occur for the association to persist:
  #          Association must be locally and bidirectionally wired before any save(),
  #          then belongsTo.save() must occur before hasMany.save():
  #            1. (existing Business)
  #            2. locally create newSpinnerShift with business set, no save()
  #            3. add newSpinnerShift to business.spinnerShifts, no save()
  #            4. newSpinnerShift.save()
  #            5. business.save()
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  name: DS.attr 'string'
  address: DS.attr 'string'

  # Add a SpinnerShift to this Business.
  #
  # @param spinnerShift {SpinnerShift} - new SpinnerShift to add to this business
  #   WARNING - spinnerShift should have been set to this business on creation, but not yet saved()  
  #
  # WARNING: As of emberfire 1.2.6, this order of events must occur for the association to persist:
  #          Association must be locally and bidirectionally wired before any save(),
  #          then belongsTo.save() must occur before hasMany.save():
  #            1. (existing Business)
  #            2. locally create newSpinnerShift with business set, no save()
  #            3. add newSpinnerShift to business.spinnerShifts, no save()
  #            4. newSpinnerShift.save()
  #            5. business.save()
  #
  # @return {Promise} Returns a promise that resolves when the passed spinnerShift has been added to this business, however the business hasn't been save()
  addSpinnerShift: (spinnerShift) ->
    _this = this
    @get('spinnerShifts').then (spinnerShifts) ->
      spinnerShifts.addObject spinnerShift
      Ember.Logger.debug 'Business.addSpinnerShift, added spinnerShift ' + spinnerShift.get('id') + ' to business ' + _this.get('id') + '. Has not been save()'

  # Save this Business and rollback if the save fails.
  # Rolling back ensures local and remote data are syncd
  rollbackUnlessSave: ->
    _this = this
    @save().catch (reason) ->
          Ember.Logger.error "Business " + _this.get('id') + " save() failed. Rolling back. Reason " + reason
          _this.rollback()
          throw reason

`export default Business`
