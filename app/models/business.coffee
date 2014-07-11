`import DS from 'ember-data'`

Business = DS.Model.extend
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  name: DS.attr 'string'
  address: DS.attr 'string'

  # Add a SpinnerShift to this Business. Mutate and save only this Business; the SpinnerShift is updated elsewhere.
  addSpinnerShift: (spinnerShift) ->
    _business = this
    this.get('spinnerShifts').then (spinnerShifts) ->
        spinnerShifts.addObject spinnerShift
        _business.save()

`export default Business`
