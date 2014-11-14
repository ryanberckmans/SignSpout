`import DS from 'ember-data'`

Business = DS.Model.extend
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  name: DS.attr 'string'
  address: DS.attr 'string'
  phone: DS.attr 'string'

`export default Business`
