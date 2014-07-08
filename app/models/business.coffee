`import DS from 'ember-data'`

Business = DS.Model.extend
  name: DS.attr 'string'
  address: DS.attr 'string'


Business.reopenClass
  FIXTURES: [
    { 
      id: "larry's-giant-subs"
      name: "Larry's Giant Subs"
      address: "4479 Deerwood Lake Pkwy #1, Jacksonville, FL 32216"
    }
    { 
      id: "cricket-wireless"
      name: "Cricket Wireless"
      address: "8221 Southside Blvd #13, Jacksonville, FL 32256"
    }
  ]

`export default Business`
