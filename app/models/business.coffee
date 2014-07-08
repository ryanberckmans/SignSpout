`import DS from 'ember-data'`

Business = DS.Model.extend
  name: DS.attr 'string'


Business.reopenClass
  FIXTURES: [
    { id: "larry's-giant-subs", name: "Larry's Giant Subs" }
    { id: "cricket-wireless", name: "Cricket Wireless" }
  ]

`export default Business`
