`import DS from 'ember-data'`

Spinner = DS.Model.extend
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  firstName: DS.attr 'string'
  lastName: DS.attr 'string'

Spinner.reopenClass
  FIXTURES: [
    {
      id: 'ryan-berckmans'
      spinnerShifts: [2,3]
      firstName: 'Ryan'
      lastName: 'Berckmans'
    }
    {
      id: 'toby'
      spinnerShifts: [1]
      firstName: 'Toby'
      lastName: 'Jones Berckmans'
    }
  ]

`export default Spinner`
