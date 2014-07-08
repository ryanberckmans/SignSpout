`import DS from 'ember-data'`

Business = DS.Model.extend
  spinnerShifts: DS.hasMany 'spinner-shift', { async: true }
  name: DS.attr 'string'
  address: DS.attr 'string'

Business.reopenClass
  FIXTURES: [
    { 
      id: "larry's-giant-subs"
      name: "Larry's Giant Subs"
      address: "4479 Deerwood Lake Pkwy #1, Jacksonville, FL 32216"
      spinnerShifts: [3]
    }
    { 
      id: "cricket-wireless"
      name: "Cricket Wireless"
      address: "8221 Southside Blvd #13, Jacksonville, FL 32256"
      spinnerShifts: [1,2]
    }
  ]

`export default Business`
