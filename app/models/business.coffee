`import DS from 'ember-data'`

Business = DS.Model.extend
  # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
  # Ie, SpinnerShift.belongsTo Business must be set BEFORE Business.hasMany SpinnerShift.
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  name: DS.attr 'string'
  address: DS.attr 'string'
  phone: DS.attr 'string'

  # Add a SpinnerShift to this Business. Mutate and save only this Business; the SpinnerShift is updated elsewhere.
  # @return {Promise} Returns a promise that resolves when spinnerShift has been added to this business
  addSpinnerShift: (spinnerShift) ->
    _business = this
    this.get('spinnerShifts').then (spinnerShifts) ->
        spinnerShifts.addObject spinnerShift
        _business.save().catch (reason) ->
          Ember.Logger.error "Business " + _business.get('id') + " save() failed on addSpinnerShift with spinnerShift " + spinnerShift.get('id') + ". Rolling back this Business. Reason " + reason
          _business.rollback()
          throw reason

`export default Business`
